# Daedalus

![Pharo](https://img.shields.io/badge/Pharo-13-blue)
![Spec2](https://img.shields.io/badge/Spec-2-orange)
![Status](https://img.shields.io/badge/status-research-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Daedalus is a visual UI designer for the Pharo environment built on top of Spec 2.

It allows developers to visually create and edit interfaces, modify component properties, and automatically generate presenter source code directly inside the live image.

## Features

- Visual interface designer for Spec 2
- Live preview of presenters
- AST-based source code generation
- Property editor
- Widget palette
- Layout editor
- Calypso integration
- Runtime presenter modification

## Technologies

- Pharo
- Smalltalk
- Spec 2
- Morphic
- OpalCompiler
- Refactoring-Core

## Architecture

The designer consists of four main areas:

- Widget Palette
- Canvas Preview
- Property Panel
- Layout Editor

Daedalus modifies `initializePresenters` and `defaultLayout` methods directly using AST transformations.
