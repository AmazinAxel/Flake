<!doctype html>
<meta charset="utf-8" />
<meta name="color-scheme" content="dark light" />
<meta name="robots" content="noindex" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>~</title>

<style>
  :root {
    --border-radius: 1rem;
    --color-background: #111;
    --color-text-subtle: #888;
    --color-text: #eee;
    --font-family: -apple-system, Helvetica, sans-serif;
    --font-size: clamp(16px, 1.6vw, 18px);
    --font-weight-bold: 700;
    --font-weight-normal: 400;
    --space: 1rem;
    --transition-speed: 200ms;
  }

  @media (prefers-color-scheme: light) {
    :root {
      --color-background: #e8e8e8;
      --color-text-subtle: #606060;
      --color-text: #111;
    }
  }
</style>

<script>
  const CONFIG = {
    commandPathDelimiter: '/',
    commandSearchDelimiter: ' ',
    defaultSearchTemplate: 'https://www.bing.com/search?q={}',
    openLinksInNewTab: true,
    suggestionLimit: 4,
  };

  const COMMANDS = new Map([
    ['g', { 
      name: 'GitHub', 
      url: 'https://github.com',
      searchTemplate: 'search?q={}',
      suggestions: ['Site', ''], 
    }],
    ['t', { name: 'Translate', url: 'https://www.deepl.com/translator' }],
    ['c', { name: 'Cloudflare', url: 'https://dash.cloudflare.com' }],
    ['l', {
      name: 'localhost',
      searchTemplate: ':{}',
      suggestions: ['54323', '54324'],
      url: 'http://localhost:3000',
    }],
  ]);
</script>

<template id="commands-template">
  <style>
    .commands {
      border-radius: var(--border-radius);
      column-gap: 0;
      columns: 1;
      list-style: none;
      margin: 0 auto;
      max-width: 10rem;
      overflow: hidden;
      padding: 0;
      width: 100vw;
    }

    .command {
      display: flex;
      gap: var(--space);
      outline: 0;
      padding: var(--space);
      position: relative;
      text-decoration: none;
    }

    .command::after {
      background: var(--color-text-subtle);
      content: ' ';
      inset: 1px;
      opacity: 0.05;
      position: absolute;
      transition: opacity var(--transition-speed);
    }

    .command:where(:focus, :hover)::after {
      opacity: 0.1;
    }

    .key {
      color: var(--color-text);
      display: inline-block;
      text-align: center;
      width: 3ch;
    }

    .name {
      color: var(--color-text-subtle);
      transition: color var(--transition-speed);
    }

    .command:where(:focus, :hover) .name {
      color: var(--color-text);
    }

    @media (min-width: 500px) {
      .commands {
        columns: 2;
        max-width: 25rem;
      }
    }

    @media (min-width: 900px) {
      .commands {
        columns: 4;
        max-width: 45rem;
      }
    }
  </style>
  <nav>
    <menu class="commands"></menu>
  </nav>
</template>

<template id="command-template">
  <li>
    <a class="command" rel="noopener noreferrer">
      <span class="key"></span>
      <span class="name"></span>
    </a>
  </li>
</template>

<script type="module">
  class Commands extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' });
      const template = document.getElementById('commands-template');
      const clone = template.content.cloneNode(true);
      const commands = clone.querySelector('.commands');
      const commandTemplate = document.getElementById('command-template');

      for (const [key, { name, url }] of COMMANDS.entries()) {
        if (!name || !url) continue;
        const clone = commandTemplate.content.cloneNode(true);
        const command = clone.querySelector('.command');
        command.href = url;
        if (CONFIG.openLinksInNewTab) command.target = '_blank';
        clone.querySelector('.key').innerText = key;
        clone.querySelector('.name').innerText = name;
        commands.append(clone);
      }

      this.shadowRoot.append(clone);
    }
  }

  customElements.define('commands-component', Commands);
</script>

<template id="search-template">
  <style>
    input,
    button {
      background: transparent;
      border: 0;
      display: block;
      outline: 0;
    }

    .dialog {
      align-items: center;
      background: var(--color-background);
      border: none;
      display: none;
      flex-direction: column;
      height: 100%;
      justify-content: center;
      left: 0;
      padding: 0;
      top: 0;
      width: 100%;
    }

    .dialog[open] {
      display: flex;
    }

    .form {
      width: 100%;
    }

    .input {
      color: var(--color-text);
      font-size: 3rem;
      font-weight: var(--font-weight-bold);
      padding: 0;
      text-align: center;
      width: 100%;
    }

    .suggestions {
      align-items: center;
      display: flex;
      flex-direction: column;
      flex-wrap: wrap;
      justify-content: center;
      list-style: none;
      margin: var(--space) 0 0;
      overflow: hidden;
      padding: 0;
    }

    .suggestion {
      color: var(--color-text);
      cursor: pointer;
      font-size: 1rem;
      padding: var(--space);
      position: relative;
      transition: color var(--transition-speed);
      white-space: nowrap;
      z-index: 1;
    }

    .suggestion:where(:focus, :hover) {
      color: var(--color-background);
    }

    .suggestion::before {
      background-color: var(--color-text);
      border-radius: calc(var(--border-radius) / 5);
      content: ' ';
      inset: calc(var(--space) / 1.5) calc(var(--space) / 3);
      opacity: 0;
      position: absolute;
      transform: translateY(0.5em);
      transition: all var(--transition-speed);
      z-index: -1;
    }

    .suggestion:where(:focus, :hover)::before {
      opacity: 1;
      transform: translateY(0);
    }

    .match {
      color: var(--color-text-subtle);
      transition: color var(--transition-speed);
    }

    .suggestion:where(:focus, :hover) .match {
      color: var(--color-background);
    }

    @media (min-width: 700px) {
      .suggestions {
        flex-direction: row;
      }
    }
  </style>
  <dialog class="dialog">
    <form autocomplete="off" class="form" method="dialog" spellcheck="false">
      <input class="input" title="search" type="text" />
      <menu class="suggestions"></menu>
    </form>
  </dialog>
</template>

<template id="suggestion-template">
  <li>
    <button class="suggestion" type="button"></button>
  </li>
</template>

<template id="match-template">
  <span class="match"></span>
</template>

<script type="module">
  class Search extends HTMLElement {
    #dialog;
    #form;
    #input;
    #suggestions;

    constructor() {
      super();
      this.attachShadow({ mode: 'open' });
      const template = document.getElementById('search-template');
      const clone = template.content.cloneNode(true);
      this.#dialog = clone.querySelector('.dialog');
      this.#form = clone.querySelector('.form');
      this.#input = clone.querySelector('.input');
      this.#suggestions = clone.querySelector('.suggestions');
      this.#form.addEventListener('submit', this.#onSubmit, false);
      this.#input.addEventListener('input', this.#onInput);
      this.#suggestions.addEventListener('click', this.#onSuggestionClick);
      document.addEventListener('keydown', this.#onKeydown);
      this.shadowRoot.append(clone);
    }

    static #escapeRegexCharacters(s) {
      return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    }

    static #fetchDuckDuckGoSuggestions(search) {
      return new Promise((resolve) => {
        window.autocompleteCallback = (res) => {
          const suggestions = [];

          for (const item of res) {
            if (item.phrase === search.toLowerCase()) continue;
            suggestions.push(item.phrase);
          }

          resolve(suggestions);
        };

        const script = document.createElement('script');
        document.querySelector('head').appendChild(script);
        script.src = `https://duckduckgo.com/ac/?callback=autocompleteCallback&q=${search}`;
        script.onload = script.remove;
      });
    }

    static #formatSearchUrl(url, searchPath, search) {
      if (!searchPath) return url;
      const [baseUrl] = Search.#splitUrl(url);
      const urlQuery = encodeURIComponent(search);
      searchPath = searchPath.replace(/{}/g, urlQuery);
      return baseUrl + searchPath;
    }

    static #hasProtocol(s) {
      return /^[a-zA-Z]+:\/\//i.test(s);
    }

    static #isUrl(s) {
      return /^((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)$/i.test(s);
    }

    static #parseQuery = (raw) => {
      const query = raw.trim();

      if (this.#isUrl(query)) {
        const url = this.#hasProtocol(query) ? query : `https://${query}`;
        return { query, url };
      }

      if (COMMANDS.has(query)) {
        const { command, key, url } = COMMANDS.get(query);
        return command ? Search.#parseQuery(command) : { key, query, url };
      }

      let splitBy = CONFIG.commandSearchDelimiter;
      const [searchKey, rawSearch] = query.split(new RegExp(`${splitBy}(.*)`));

      if (COMMANDS.has(searchKey)) {
        const { searchTemplate, url: base } = COMMANDS.get(searchKey);
        const search = rawSearch.trim();
        const url = Search.#formatSearchUrl(base, searchTemplate, search);
        return { key: searchKey, query, search, splitBy, url };
      }

      splitBy = CONFIG.commandPathDelimiter;
      const [pathKey, path] = query.split(new RegExp(`${splitBy}(.*)`));

      if (COMMANDS.has(pathKey)) {
        const { url: base } = COMMANDS.get(pathKey);
        const [baseUrl] = Search.#splitUrl(base);
        const url = `${baseUrl}/${path}`;
        return { key: pathKey, path, query, splitBy, url };
      }

      const [baseUrl, rest] = Search.#splitUrl(CONFIG.defaultSearchTemplate);
      const url = Search.#formatSearchUrl(baseUrl, rest, query);
      return { query, search: query, url };
    };

    static #splitUrl(url) {
      const parser = document.createElement('a');
      parser.href = url;
      const baseUrl = `${parser.protocol}//${parser.hostname}`;
      const rest = `${parser.pathname}${parser.search}`;
      return [baseUrl, rest];
    }

    #close() {
      this.#input.value = '';
      this.#input.blur();
      this.#dialog.close();
      this.#suggestions.innerHTML = '';
    }

    #execute(query) {
      const { url } = Search.#parseQuery(query);
      const target = CONFIG.openLinksInNewTab ? '_blank' : '_self';
      window.open(url, target, 'noopener noreferrer');
      this.#close();
    }

    #focusNextSuggestion(previous = false) {
      const active = this.shadowRoot.activeElement;
      let nextIndex;

      if (active.dataset.index) {
        const activeIndex = Number(active.dataset.index);
        nextIndex = previous ? activeIndex - 1 : activeIndex + 1;
      } else {
        nextIndex = previous ? this.#suggestions.childElementCount - 1 : 0;
      }

      const next = this.#suggestions.children[nextIndex];
      if (next) next.querySelector('.suggestion').focus();
      else this.#input.focus();
    }

    #onInput = async () => {
      const oq = Search.#parseQuery(this.#input.value);

      if (!oq.query) {
        this.#close();
        return;
      }

      let suggestions = COMMANDS.get(oq.query)?.suggestions ?? [];

      if (oq.search && suggestions.length < CONFIG.suggestionLimit) {
        const res = await Search.#fetchDuckDuckGoSuggestions(oq.search);

        suggestions = suggestions.concat(
          oq.splitBy
            ? res.map((search) => `${oq.key}${oq.splitBy}${search}`)
            : res
        );
      }

      const nq = Search.#parseQuery(this.#input.value);
      if (nq.query !== oq.query) return;
      this.#renderSuggestions(suggestions, oq.query);
    };

    #onKeydown = (e) => {
      if (!this.#dialog.open) {
        this.#dialog.show();
        this.#input.focus();

        requestAnimationFrame(() => {
          // close the search dialog before the next repaint if a character is
          // not produced (e.g. if you type shift, control, alt etc.)
          if (!this.#input.value) this.#close();
        });

        return;
      }

      if (e.key === 'Escape') {
        this.#close();
        return;
      }

      const alt = e.altKey ? 'alt-' : '';
      const ctrl = e.ctrlKey ? 'ctrl-' : '';
      const meta = e.metaKey ? 'meta-' : '';
      const shift = e.shiftKey ? 'shift-' : '';
      const modifierPrefixedKey = `${alt}${ctrl}${meta}${shift}${e.key}`;

      if (/^(ArrowDown|Tab|ctrl-n)$/.test(modifierPrefixedKey)) {
        e.preventDefault();
        this.#focusNextSuggestion();
        return;
      }

      if (/^(ArrowUp|ctrl-p|shift-Tab)$/.test(modifierPrefixedKey)) {
        e.preventDefault();
        this.#focusNextSuggestion(true);
      }
    };

    #onSubmit = () => {
      this.#execute(this.#input.value);
    };

    #onSuggestionClick = (e) => {
      const ref = e.target.closest('.suggestion');
      if (!ref) return;
      this.#execute(ref.dataset.suggestion);
    };

    #renderSuggestions(suggestions, query) {
      this.#suggestions.innerHTML = '';
      const sliced = suggestions.slice(0, CONFIG.suggestionLimit);
      const template = document.getElementById('suggestion-template');

      for (const [index, suggestion] of sliced.entries()) {
        const clone = template.content.cloneNode(true);
        const ref = clone.querySelector('.suggestion');
        ref.dataset.index = index;
        ref.dataset.suggestion = suggestion;
        const escapedQuery = Search.#escapeRegexCharacters(query);
        const matched = suggestion.match(new RegExp(escapedQuery, 'i'));

        if (matched) {
          const template = document.getElementById('match-template');
          const clone = template.content.cloneNode(true);
          const matchRef = clone.querySelector('.match');
          const pre = suggestion.slice(0, matched.index);
          const post = suggestion.slice(matched.index + matched[0].length);
          matchRef.innerText = matched[0];
          matchRef.insertAdjacentHTML('beforebegin', pre);
          matchRef.insertAdjacentHTML('afterend', post);
          ref.append(clone);
        } else {
          ref.innerText = suggestion;
        }

        this.#suggestions.append(clone);
      }
    }
  }

  customElements.define('search-component', Search);
</script>

<style>
  html {
    background-color: var(--color-background);
    font-family: var(--font-family);
    font-size: var(--font-size);
    line-height: 1.4;
  }

  body {
    margin: 0;
  }

  main {
    align-items: center;
    box-sizing: border-box;
    display: flex;
    justify-content: center;
    min-height: 100vh;
    overflow: hidden;
    padding: calc(var(--space) * 4) var(--space);
    position: relative;
    width: 100vw;
  }
</style>

<main>
  <commands-component></commands-component>
  <search-component></search-component>
</main>