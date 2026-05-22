#!/usr/bin/env python3

import atexit
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path


DEBEZIUM_BASE_URL = "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres"
DEBEZIUM_RELEASES_URL = "https://debezium.io/releases/"
MSK_CONFIG_PROVIDER_BASE_URL = "https://github.com/aws-samples/msk-config-providers/releases/download"
MSK_CONFIG_PROVIDER_RELEASES_URL = "https://github.com/aws-samples/msk-config-providers/releases"
DEFAULT_MSK_CONFIG_PROVIDER_VERSION = "0.4.0"
DEFAULT_DEBEZIUM_VERSION = "3.5.0"

SCRIPT_PATH = Path(__file__).resolve()
MODULE_DIR = SCRIPT_PATH.parent.parent
WORK_ROOT = MODULE_DIR / ".plugin-build"

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
BOLD = "\033[1m"
RESET = "\033[0m"


class ScriptError(Exception):
    pass


class BuilderState:
    def __init__(self) -> None:
        self.debezium_version = ""
        self.debezium_archive_version = ""
        self.debezium_archive_name = ""
        self.debezium_archive_url = ""
        self.msk_config_provider_version = ""
        self.aws_region = ""
        self.auth_mode = "current"
        self.aws_profile = ""
        self.role_arn = ""
        self.role_session_name = ""
        self.s3_bucket = ""
        self.s3_prefix = ""
        self.plugin_zip_name = ""
        self.custom_plugin_name = ""
        self.confirm_overwrite = False


STATE = BuilderState()


def print_header(message: str) -> None:
    print()
    print(f"{BOLD}{BLUE}== {message} =={RESET}")


def print_info(message: str) -> None:
    print(f"{BLUE}[info]{RESET} {message}")


def print_success(message: str) -> None:
    print(f"{GREEN}[ok]{RESET} {message}")


def print_warning(message: str) -> None:
    print(f"{YELLOW}[warn]{RESET} {message}", file=sys.stderr)


def print_error(message: str) -> None:
    print(f"{RED}[error]{RESET} {message}", file=sys.stderr)


def print_progress(message: str) -> None:
    print(f"\r{BLUE}[download]{RESET} {message}", end="", flush=True)


def finish_progress() -> None:
    print()


def require_command(command_name: str) -> None:
    if shutil.which(command_name) is None:
        raise ScriptError(f"Required command not found: {command_name}")


def trim(value: str) -> str:
    return value.strip()


def sanitize_version_for_name(value: str) -> str:
    return re.sub(r"[.+]", "-", value)


def normalize_s3_prefix(value: str) -> str:
    normalized = trim(value).strip("/")
    return normalized


def prompt_value(prompt_text: str, default_value: str = "") -> str:
    if default_value:
        response = input(f"{prompt_text} [{default_value}]: ")
    else:
        response = input(f"{prompt_text}: ")

    response = trim(response)
    if not response:
        return default_value
    return response


def prompt_non_empty(prompt_text: str, default_value: str = "") -> str:
    while True:
        response = prompt_value(prompt_text, default_value)
        if response:
            return response
        print_warning("A value is required.")


def prompt_yes_no(prompt_text: str, default_answer: str = "y") -> bool:
    alternate = "n" if default_answer == "y" else "y"
    while True:
        response = input(f"{prompt_text} [{default_answer}/{alternate}]: ")
        response = trim(response) or default_answer
        lowered = response.lower()
        if lowered in {"y", "yes"}:
            return True
        if lowered in {"n", "no"}:
            return False
        print_warning("Please answer y or n.")


def prompt_auth_mode() -> str:
    while True:
        response = input(
            "Authentication mode: press Enter for current AWS credentials, 1 for AWS profile, or 2 for IAM role: "
        )
        response = trim(response)
        if response == "":
            return "current"
        if response == "1":
            return "profile"
        if response == "2":
            return "role"
        print_warning("Please press Enter, 1, or 2.")


def build_debezium_meta(version: str) -> tuple[str, str, str]:
    archive_version = f"{version}.Final"
    archive_name = f"debezium-connector-postgres-{archive_version}-plugin.tar.gz"
    archive_url = f"{DEBEZIUM_BASE_URL}/{archive_version}/{archive_name}"
    return archive_version, archive_name, archive_url


def validate_http_url(url: str) -> bool:
    request = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(request):
            return True
    except urllib.error.HTTPError as exc:
        if exc.code == 405:
            try:
                with urllib.request.urlopen(url):
                    return True
            except Exception:
                return False
        return False
    except Exception:
        return False


def detect_default_region() -> str:
    env = os.environ.copy()
    try:
        result = subprocess.run(
            ["aws", "configure", "get", "region"],
            check=False,
            capture_output=True,
            text=True,
            env=env,
        )
    except OSError:
        return ""

    if result.returncode != 0:
        return ""
    return trim(result.stdout)


def run_aws_command(args: list[str], capture_output: bool = False) -> subprocess.CompletedProcess:
    env = os.environ.copy()
    return subprocess.run(
        args,
        check=True,
        text=True,
        capture_output=capture_output,
        env=env,
    )


def assume_role_if_requested() -> None:
    if not STATE.role_arn:
        return

    print_info(f"Assuming IAM role {STATE.role_arn}")

    session_name = STATE.role_session_name or "debezium-plugin-build"
    result = run_aws_command(
        [
            "aws",
            "sts",
            "assume-role",
            "--role-arn",
            STATE.role_arn,
            "--role-session-name",
            session_name,
            "--output",
            "json",
        ],
        capture_output=True,
    )

    payload = json.loads(result.stdout)
    credentials = payload["Credentials"]
    os.environ.pop("AWS_PROFILE", None)
    os.environ["AWS_ACCESS_KEY_ID"] = credentials["AccessKeyId"]
    os.environ["AWS_SECRET_ACCESS_KEY"] = credentials["SecretAccessKey"]
    os.environ["AWS_SESSION_TOKEN"] = credentials["SessionToken"]

    print_success("Role assumed successfully.")


def validate_bucket_access() -> None:
    print_info(f"Validating access to s3://{STATE.s3_bucket}")
    run_aws_command(["aws", "s3api", "head-bucket", "--bucket", STATE.s3_bucket])


def resolve_bucket_region() -> str:
    result = run_aws_command(
        [
            "aws",
            "s3api",
            "get-bucket-location",
            "--bucket",
            STATE.s3_bucket,
            "--output",
            "json",
        ],
        capture_output=True,
    )
    payload = json.loads(result.stdout)
    bucket_region = payload.get("LocationConstraint")
    if bucket_region in (None, "None"):
        return "us-east-1"
    return str(bucket_region)


def build_s3_uri() -> str:
    if STATE.s3_prefix:
        return f"s3://{STATE.s3_bucket}/{STATE.s3_prefix}/{STATE.plugin_zip_name}"
    return f"s3://{STATE.s3_bucket}/{STATE.plugin_zip_name}"


def cleanup_workspace() -> None:
    if WORK_ROOT.exists():
        shutil.rmtree(WORK_ROOT)


def prepare_workspace() -> None:
    cleanup_workspace()
    (WORK_ROOT / "custom-plugin").mkdir(parents=True, exist_ok=True)


def download_file(url: str, destination: Path) -> None:
    chunk_size = 1024 * 1024
    with urllib.request.urlopen(url) as response, destination.open("wb") as handle:
        total_bytes_header = response.headers.get("Content-Length")
        total_bytes = int(total_bytes_header) if total_bytes_header else 0
        downloaded_bytes = 0

        while True:
            chunk = response.read(chunk_size)
            if not chunk:
                break

            handle.write(chunk)
            downloaded_bytes += len(chunk)

            if total_bytes > 0:
                percentage = (downloaded_bytes / total_bytes) * 100
                print_progress(
                    f"{downloaded_bytes:,}/{total_bytes:,} bytes ({percentage:.1f}%)"
                )
            else:
                print_progress(f"{downloaded_bytes:,} bytes")

    finish_progress()


def download_and_extract_debezium() -> None:
    archive_path = WORK_ROOT / STATE.debezium_archive_name

    print_info("Downloading Debezium plugin archive")
    download_file(STATE.debezium_archive_url, archive_path)

    print_info("Extracting Debezium plugin archive")
    with tarfile.open(archive_path, "r:gz") as archive:
        archive.extractall(WORK_ROOT / "custom-plugin")
    archive_path.unlink()


def download_and_extract_config_provider() -> None:
    version = STATE.msk_config_provider_version
    release_tag = f"r{version}"
    archive_name = f"msk-config-providers-{version}-with-dependencies.zip"
    archive_url = f"{MSK_CONFIG_PROVIDER_BASE_URL}/{release_tag}/{archive_name}"
    archive_path = WORK_ROOT / archive_name

    print_info("Validating MSK config provider archive URL")
    if not validate_http_url(archive_url):
        raise ScriptError(f"MSK config provider version {version} is not available at {archive_url}")

    print_info("Downloading MSK config provider archive")
    download_file(archive_url, archive_path)

    print_info("Extracting MSK config provider archive")
    with zipfile.ZipFile(archive_path) as archive:
        archive.extractall(WORK_ROOT / "custom-plugin")
    archive_path.unlink()


def create_plugin_zip() -> None:
    zip_path = MODULE_DIR / STATE.plugin_zip_name

    if zip_path.exists() and not STATE.confirm_overwrite:
        print_warning(f"Output file already exists: {zip_path}")
        if not prompt_yes_no("Overwrite the existing ZIP file?", "n"):
            raise ScriptError(f"Aborted to avoid overwriting {zip_path}")

    print_info("Creating plugin ZIP archive")
    if zip_path.exists():
        zip_path.unlink()

    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted((WORK_ROOT / "custom-plugin").rglob("*")):
            if path.is_file():
                archive.write(path, path.relative_to(WORK_ROOT / "custom-plugin"))

    print_success(f"Plugin ZIP created at {zip_path}")


def upload_plugin_zip() -> None:
    zip_path = MODULE_DIR / STATE.plugin_zip_name
    s3_uri = build_s3_uri()

    print_info(f"Uploading plugin ZIP to {s3_uri}")
    run_aws_command(["aws", "s3", "cp", str(zip_path), s3_uri])
    print_success(f"Upload completed: {s3_uri}")


def print_summary() -> None:
    print_header("Summary")
    print(f"Debezium version:            {STATE.debezium_version}")
    print(f"Debezium archive version:    {STATE.debezium_archive_version}")
    print(f"MSK config provider version: {STATE.msk_config_provider_version}")
    print(f"AWS region:                  {STATE.aws_region}")
    print(f"Authentication mode:         {STATE.auth_mode}")
    print(f"AWS profile:                 {STATE.aws_profile or 'current AWS credentials'}")
    print(f"IAM role:                    {STATE.role_arn or '<none>'}")
    print(f"S3 bucket:                   {STATE.s3_bucket}")
    print(f"S3 prefix:                   {STATE.s3_prefix or '<root>'}")
    print(f"Plugin ZIP:                  {STATE.plugin_zip_name}")
    print(f"Suggested plugin name:       {STATE.custom_plugin_name}")
    print(f"S3 destination:              {build_s3_uri()}")


def collect_inputs() -> None:
    print_header("Build Inputs")
    print_info("Available Debezium plugin versions:")
    print(f"       {DEBEZIUM_RELEASES_URL}")

    while True:
        STATE.debezium_version = prompt_non_empty(
            "Debezium PostgreSQL connector version",
            DEFAULT_DEBEZIUM_VERSION,
        )
        (
            STATE.debezium_archive_version,
            STATE.debezium_archive_name,
            STATE.debezium_archive_url,
        ) = build_debezium_meta(STATE.debezium_version)

        print_info(f"Checking Debezium archive availability: {STATE.debezium_archive_url}")
        if validate_http_url(STATE.debezium_archive_url):
            print_success(f"Debezium version {STATE.debezium_archive_version} is available.")
            break
        print_warning(f"Debezium version {STATE.debezium_archive_version} was not found.")

    while True:
        print_info("Available MSK config provider versions:")
        print(f"       {MSK_CONFIG_PROVIDER_RELEASES_URL}")
        STATE.msk_config_provider_version = prompt_non_empty(
            "MSK config provider version",
            DEFAULT_MSK_CONFIG_PROVIDER_VERSION,
        )
        config_url = (
            f"{MSK_CONFIG_PROVIDER_BASE_URL}/r{STATE.msk_config_provider_version}/"
            f"msk-config-providers-{STATE.msk_config_provider_version}-with-dependencies.zip"
        )
        print_info(f"Checking MSK config provider availability: {config_url}")
        if validate_http_url(config_url):
            print_success(f"MSK config provider version {STATE.msk_config_provider_version} is available.")
            break
        print_warning(f"MSK config provider version {STATE.msk_config_provider_version} was not found.")

    STATE.auth_mode = prompt_auth_mode()

    if STATE.auth_mode == "profile":
        STATE.aws_profile = prompt_non_empty("AWS profile name")
        os.environ["AWS_PROFILE"] = STATE.aws_profile
        print_info(f"Using AWS profile {STATE.aws_profile}")
    else:
        os.environ.pop("AWS_PROFILE", None)
        STATE.aws_profile = ""

    if STATE.auth_mode == "role":
        STATE.role_arn = prompt_non_empty("IAM role ARN to assume")
        STATE.role_session_name = prompt_value("Role session name", "debezium-plugin-build")
    else:
        STATE.role_arn = ""
        STATE.role_session_name = ""

    default_region = detect_default_region()
    STATE.aws_region = prompt_non_empty("AWS region to use for S3 and STS operations", default_region)
    os.environ["AWS_REGION"] = STATE.aws_region
    os.environ["AWS_DEFAULT_REGION"] = STATE.aws_region

    STATE.s3_bucket = prompt_non_empty("S3 bucket name")
    STATE.s3_prefix = normalize_s3_prefix(prompt_value("Optional S3 key prefix (press Enter for bucket root)"))

    default_zip_name = f"postgres-msk-debezium-plugin-{STATE.debezium_version}.zip"
    STATE.plugin_zip_name = prompt_non_empty("Local output ZIP filename", default_zip_name)

    default_plugin_name = f"postgresql-msk-debezium-connector-{sanitize_version_for_name(STATE.debezium_version)}"
    STATE.custom_plugin_name = prompt_non_empty("Suggested MSK Connect custom plugin name", default_plugin_name)

    STATE.confirm_overwrite = not (MODULE_DIR / STATE.plugin_zip_name).exists()


def main() -> int:
    require_command("aws")

    print_header("Debezium MSK Connect Plugin Builder")
    print("This script builds the Debezium PostgreSQL MSK Connect plugin ZIP and uploads it to S3.")
    print("It validates artifact URLs before downloading and can optionally assume an IAM role first.")

    collect_inputs()
    print_summary()

    if not prompt_yes_no("Proceed with build and upload?", "y"):
        raise ScriptError("Aborted by user.")

    assume_role_if_requested()
    validate_bucket_access()

    bucket_region = resolve_bucket_region()
    if bucket_region != STATE.aws_region:
        print_warning(f"Bucket region is {bucket_region}, while the selected AWS region is {STATE.aws_region}.")

    prepare_workspace()
    atexit.register(cleanup_workspace)

    download_and_extract_debezium()
    download_and_extract_config_provider()
    create_plugin_zip()
    upload_plugin_zip()

    print_success("Plugin build and upload completed successfully.")
    print()
    print("Terraform module input reference:")
    print(f"  custom_plugin_name = \"{STATE.custom_plugin_name}\"")
    print(f"  S3 object          = {build_s3_uri()}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print_error("Interrupted by user.")
        sys.exit(130)
    except subprocess.CalledProcessError as exc:
        print_error(f"Command failed with exit code {exc.returncode}: {' '.join(exc.cmd)}")
        sys.exit(exc.returncode)
    except ScriptError as exc:
        print_error(str(exc))
        sys.exit(1)
