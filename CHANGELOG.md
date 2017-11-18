# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Output every xml tag from a diff doc on it's own line

## [0.2.0] - 2017-11-09
### Fixed
- Expect patch xml to have a <diff> root node
- Don't parse nested <remove> tags

## [0.1.0] - 2017-11-01
### Added
- Support for <remove> xml patch elements
