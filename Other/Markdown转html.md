# Markdown转html

## 准备工作

1. 下载[pandoc](https://github.com/jgm/pandoc/releases/latest)
1. 下载[github-markdown-light.css](https://github.com/sindresorhus/github-markdown-css)（可以自由选择light或者dark等样式）。

## 创建html模板

+ `github-template.html`

    ```html
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="utf-8">
        <title>$title$</title>
        <link rel="stylesheet" href="github-markdown-light.css">
        <style>
            body {
                box-sizing: border-box;
                margin: auto;
                padding: 45px;
            }
        </style>
    </head>

    <body>
        <article class="markdown-body">
            $body$
        </article>
    </body>

    </html>
    ```

## 生成html文件

```shell
pandoc example.md --standalone --embed-resource --template=github-template.html -f gfm -t html -o example.html
```
