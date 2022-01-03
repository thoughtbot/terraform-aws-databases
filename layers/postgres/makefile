.PHONY: default clean

default: package.zip

clean:
	rm -rf package.zip python

package.zip: python
	zip -D package.zip -r python

python: requirements.txt
	mkdir -p python
	docker run \
		--user "$$(id -u "$$USER"):$$(id -g $$USER)" \
		--volume "$$PWD:/layer" \
		python:3.8 \
		pip3 install -r /layer/requirements.txt --target /layer/python
