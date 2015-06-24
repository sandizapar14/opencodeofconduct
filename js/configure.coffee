---
# Hey Jekyll, please transform this file.
---

class @Configure
  constructor: (@template, @element) ->
    @form = @element.querySelector("form")
    @snippet = @element.querySelector("#snippet")

    @form.addEventListener "submit", @submit
    @element.querySelector("a[href='#configure']").addEventListener "click", @start

  start: (event) =>
    event.preventDefault()
    @element.classList.add("configuring")
    @element.classList.remove("unconfigured")
    @element.classList.remove("configured")

  submit: (event) =>
    event.preventDefault()
    @setup @data()
    @element.classList.remove("configuring")
    @element.classList.add("configured")

  # Return the form data as an object
  data: ->
    data = {}
    for element in @form.elements
      data[element.name] = element.value if element.value.length
    data

  setup: (data) ->
    @template.configure(data)
    window.location.hash = @encode(data)

    snippet = @element.querySelector("#markdown-template").innerText.trim()
    snippet = snippet.replace("[URL]", window.location)
    @snippet.value = snippet

  encode: (data) ->
    # Base64 encode the data, escaping non-ascii characters.
    # https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding#The_.22Unicode_Problem.22
    str = encodeURIComponent(JSON.stringify(data))
    escaped = str.replace /%([0-9A-F]{2})/g, (match, p1) -> String.fromCharCode('0x' + p1)
    btoa(escaped)

  decode: (string) ->
    JSON.parse(atob(string))

class Template
  constructor: (@element) ->

  configure: (data) ->
    # Make a backup copy so this can be run multiple times
    @original ?= @element.cloneNode(true)

    node = @original.cloneNode(true)

    placeholders = {}
    placeholders["[#{key.toUpperCase()}]"] = value for key, value of data

    for element in node.querySelectorAll("strong")
      for key, value of placeholders
        element.textContent = value if element.textContent == key

    @element.parentNode.replaceChild(node, @element)
    @element = node

template = new Template(element) if element = document.querySelector("#code-of-conduct")
new Configure(template, element) if element = document.getElementById("configure")
