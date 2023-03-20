# Potion Shop Self Guided 

This document assumes the reader is already familiar with web application security, and is able to find security bugs independently. 

## Exercises 

### 1. Cross Site Scripting (XSS)

Potion Shop is vulnerable to persistent XSS. Trigger the JavaScript `alert(1)`, and write a brief explanation of how an attacker would use this vulnerability to harm users. 

### 2. Cross Site Request Forgery (CSRF)

Potion Shop is vulnerable to CSRF. Create a proof of concept HTML page showing how an attacker would exploit this flaw, and explain how an attacker would use the page in a real attack.

### 3. Remote Code Execution (RCE)

Potion Shop is vulnerable to RCE. Create a proof of concept payload that causes attacker supplied code to execute on the webserver. 

### 4. SQL Injection 

Potion Shop is vulnerable to SQL injection. Show how an attacker can use this weakness to access private data from the database. What else can an attacker do with this security bug?

### 5. Broken Access Control

In Potion Shop, an attacker can create new records in the database with the wrong author. Show how this attack works, and explain the problem with the current implementation.
