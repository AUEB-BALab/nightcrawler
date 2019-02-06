import codecs
import sys
import chardet
import os

from lxml import html, etree

def get_contents(html_file_name):
    try:
        with codecs.open(html_file_name, 'r') as html_file:
            contents = html_file.read()
    except IOError:
        # Can't open file
        print "CAN'T OPEN"
        contents = None

    return contents

def find_encoding(contents):
    return chardet.detect(contents)['encoding']

def parse_html(contents, encoding=None):
    parser = etree.HTMLParser(encoding=encoding)
    return html.fromstring(contents, parser=parser)

def get_tree(contents, encoding):
    try:
        tree = parse_html(contents, encoding=encoding)
    except LookupError:
        # encoding not found, try utf-8
        return get_tree(contents, 'utf-8')
    except etree.ParserError:
        # document doesn't contain html
        return -1
    except AttributeError:
        return -2

    return tree

def get_scripts(tree):
    return tree.xpath('//script/text()')

def parse_file(html_file_name):
    contents = get_contents(html_file_name)
    if not contents:
        print "NOT CONTENTS "
        exit(1)

    encoding = find_encoding(contents)

    tree = get_tree(contents, encoding)
    if tree == -1:
        with open('/home/vitsalis/js-evolution/notree.txt', 'a') as notree_file:
            notree_file.write(html_file_name + "\n")
        exit(2)

    if tree == -2:
        print "ERROR"
        exit(2)

    try:
        scripts = get_scripts(tree)
    except UnicodeDecodeError:
        # We didn't get the correct encoding
        with open('/home/vitsalis/js-evolution/wrong_encoding.txt', 'a') as wrong_encoding_file:
            wrong_encoding_file.write(html_file_name + "\n")

        print "WRONG ENCODING"
        exit(3)

    counter = 0
    for script in scripts:
        jsf_name = html_file_name + '-jsf-' + str(counter)
        with codecs.open(jsf_name, 'w+', encoding='utf-8') as jsf_file:
            jsf_file.write(script)

        counter += 1

path = sys.argv[1]

for root, dirs, files in os.walk(path):
    for site_file in files:
        if site_file.endswith(".html"):
            parse_file(os.path.join(root, site_file))
