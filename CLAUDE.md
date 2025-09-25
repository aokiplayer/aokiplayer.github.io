# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 言語設定

**重要**: このリポジトリで作業する際は、全てのメッセージを日本語で返してください。

## Repository Overview

This is a Hugo-based Japanese blog site (Yagamo Style) hosted at https://yagamo-style.com/. The blog focuses on technical content including iOS development, Swift programming, event reports, and technical tutorials.

## Architecture

- **Hugo Site Generator**: Static site built with Hugo 0.112.1 using Docker
- **Theme**: Uses `hugo-theme-learn` as a git submodule in `themes/` directory
- **Content Structure**: Blog posts organized by year in `content/YYYY/` directories
- **Static Assets**: Images and custom CSS in `static/` directory
- **Custom Layouts**: Site-specific template overrides in `layouts/partials/`

## Essential Commands

### Development Server
```bash
./hugo-server.sh
```
Starts Hugo development server at http://localhost:1313/ with live reload. Uses Docker container with port binding.

### Create New Blog Post
```bash
./hugo-new.sh YYYY/post-name
```
Creates new blog post in `content/YYYY/post-name.md` using the default archetype template.

### Build Site
```bash
./hugo-base.sh
```
Builds the static site. Generated files appear in `public/` directory.

## Repository Setup

When cloning, use recursive clone to include the theme submodule:
```bash
git clone --recursive <repository-url>
```

## Content Guidelines

- Blog posts are written in Japanese
- Use the archetype template structure (はじめに, 検証環境, まとめ, 参考)
- Images should be placed in `static/images/post-name/` directories
- Set `ogimage` in frontmatter for social sharing

## Configuration

- Site config in `config.toml` 
- Language: Japanese (ja-JP)
- Theme variant: blue
- Custom styling in `static/css/custom.css`
- Permalink structure: `/:year/:month/:day/:filename/`
- 記事作成時は、write ブランチから article ブランチを作成。記事作成後は、article ブランチをローカルで write ブランチにマージ。write ブランチをプッシュ後は、article ブランチは削除