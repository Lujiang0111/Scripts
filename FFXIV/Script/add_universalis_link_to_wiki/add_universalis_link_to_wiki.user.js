// ==UserScript==
// @name         Add Universalis link to wiki
// @namespace    https://github.com/Lujiang0111/Scripts
// @version      1.0.0
// @description  Add Universalis link to FF14 HuijiWiki page
// @author       lujiang0111
// @match        https://ff14.huijiwiki.com/wiki/*
// @icon         https://universalis.app/favicon.png
// @homepageURL  https://github.com/Lujiang0111/Scripts
// @source       https://github.com/Lujiang0111/Scripts
// @updateURL    https://raw.githubusercontent.com/Lujiang0111/Scripts/main/FFXIV/Script/add_universalis_link_to_wiki/add_universalis_link_to_wiki.user.js
// @downloadURL  https://raw.githubusercontent.com/Lujiang0111/Scripts/main/FFXIV/Script/add_universalis_link_to_wiki/add_universalis_link_to_wiki.user.js
// @grant        none
// ==/UserScript==

'use strict';

function getItemId() {
    const itemIdLis = document.querySelectorAll('li.ff14-hardcore');

    for (const li of itemIdLis) {
        const match = li.textContent.match(/物品ID：(\d+)/);

        if (match) {
            return Number(match[1]);
        }
    }

    return null;
}

function findOtherLinksBlock() {
    const titles = document.querySelectorAll(
        '.ff14-content-box-block--title'
    );

    for (const title of titles) {
        if (title.textContent.trim() === '其他站点链接') {
            return title.closest('.ff14-content-box-block');
        }
    }

    return null;
}

function main() {
    const itemId = getItemId();
    if (itemId === null) {
        return;
    }

    const otherLinksBlock = findOtherLinksBlock();
    if (!otherLinksBlock) {
        return;
    }

    const ul = otherLinksBlock.querySelector('ul');
    if (!ul) {
        return;
    }

    if (ul.querySelector('.universalis-link')) {
        return;
    }

    const li = document.createElement('li');

    const a = Object.assign(document.createElement('a'), {
        href: `https://universalis.app/market/${itemId}`,
        target: '_blank',
        rel: 'nofollow noreferrer noopener',
        className: 'external text universalis-link'
    });

    const img = Object.assign(document.createElement('img'), {
        src: 'https://universalis.app/favicon.png',
        width: 16,
        height: 16,
        alt: 'Icon universalis.png',
        decoding: 'async'
    });

    a.append(img, ' Universalis');
    li.append(a);
    ul.append(li);
}

if (document.readyState !== 'loading') {
    main();
} else {
    document.addEventListener('DOMContentLoaded', main, { once: true });
}