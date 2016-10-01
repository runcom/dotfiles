[pastebin]
basename = pastebin.test.redhat.com
regexp = "http://pastebin.test.redhat.com"

[format]
user = amurdaca
content = code2
format = format
submit = paste

[defaults]
format = text
submit = Send
page = "/pastebin.php"
