#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const YAML = require('yaml')
const pkg = require('../package.json');
const dstPath = path.join(__dirname, '..', 'collection', 'galaxy.yml')
const dstContent = YAML.parse(fs.readFileSync(dstPath, 'utf8'));
console.log(dstPath, 'from', dstContent.version, 'to', pkg.version);
dstContent.version = pkg.version;
fs.writeFileSync(dstPath, YAML.stringify(dstContent));
