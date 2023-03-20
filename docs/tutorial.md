# Tutorial 

This document is a guide through the Potion Shop application, and a roadmap on how to uncover security issues. 

## Web Application Vulnerabilities  

### 1. Cross Site Scripting (XSS)

[Cross Site Scripting (XSS)](https://en.wikipedia.org/wiki/Cross-site_scripting) occurs when attacker controlled JavaScript is executed in the browsing session of a victim. Consider a user logged into Potion Shop, or an online banking website. The scripts running on the page should originate from a trusted origin, because that code has access to highly sensitive information, and can perform actions on behalf of the user.

A traditional way of testing for XSS is using the string `"<script>alert(1)</script>` as input to a web application. If the alert box is triggered, that part of the application is vulnerable. When describing how an application is vulnerable to XSS, it is important consider the attack scenario:

1. An online shop's review system is vulnerable to XSS. This means a victim user who view's an attacker's review will have their session hijacked. The attacker's XSS payload can spread as a worm, where victim accounts are hijacked to create additional reviews with the payload, causing additional infections. For a real world example, see the MySpace [Samy Worm](https://en.wikipedia.org/wiki/Samy_(computer_worm)). 

2. An online banking system allows users to edit their display name for a greeting. The only person who can see this greeting is the user, and it is vulnerable to XSS. The application code should be checked to ensure the vulnerable code pattern is not in other parts of the codebase, however the vulnerability on its own is low impact, because an attacker cannot use it to harm users. This is referred to as "self XSS". 

In Elixir applications, XSS is rare, because Phoenix takes care to [automatically escape HTML code](https://hexdocs.pm/phoenix_html/Phoenix.HTML.html#raw/1). However, it is still possible to introduce this flaw into a Phoenix application:

1. With the `raw/1` function

2. By passing an HTML document directly to `html/2` in your controller. For example, `html(conn, "<html><head>#{i}</head></html>")`, where `i` is user input.

3. When handling file uploads, in the response `put_resp_content_type(content_type)`. The developer may only expect image files, but if an attacker can upload an HTML document, that can lead to XSS.

See the article [Cross Site Scripting (XSS) Patterns in Phoenix](https://paraxial.io/blog/xss-phoenix) for more details. 


### 2. Cross Site Request Forgery (CSRF)

[Cross Site Request Forgery (CSRF)](https://en.wikipedia.org/wiki/Cross-site_request_forgery) involves the user making a privileged command, such as creating a new bank transaction, via a POST request in the application. These commands can be triggered by a form on a different domain, controlled by an attacker. When the victim browses to the attacker domain, a POST request is submitted on their behalf, with their session cookie attacked, but crafted by an attacker. This could be used to transfer money out of a bank account, because the attacker controls the body of the POST. 

Understanding CSRF requires some background knowledge on how HTTP, HTML forms, and different websites interact with each other. Students first learning about CSRF are often confused about how such an issue is possible. The root cause is due to how web browsers and sites interact with each other in an unexpected way. 

Modern web frameworks (Ruby on Rails, Django, Phoenix) all come with built in protection against CSRF, which has lead to a decline in the frequency this vulnerability shows up. In Phoenix, there are two parts to the CSRF protection:

1. Consider the Phoenix form

```
<.form let={f} for={@changeset} action={@action}>

  <%= label f, :title %>
  <%= text_input f, :title %>
  <%= error_tag f, :title %>

  <%= label f, :body %>
  <%= textarea f, :body %>
  <%= error_tag f, :body %>

  <%= submit "Save" %>
</.form>
```

This will generate an HTML form:

```
<form action="/projects" method="post">
  <input name="_csrf_token" type="hidden" value="CRckEHQMIzJ9A1xkBkYvDwl3GWEKAVsiYSOg8ARaHae7_4zJVAjXLI9j">

  <label for="project_title">Title</label>
  <input id="project_title" name="project[title]" type="text">
  
  <label for="project_body">Body</label>
  <textarea id="project_body" name="project[body]">
  </textarea>
  
  <button type="submit">Save</button>
</form>
```

The `_csrf_token` is submitted with the form, then checked by the backend server. An attacker cannot see the value of the token, they can only initiate a POST request on behalf of the user that matches the above form. 

Does the presence of a CSRF token in an HTML form mean the application is safe? The answer is no, because the server must reject POST requests with an invalid token. This validation is done by default in the Phoenix router:

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug :put_root_layout, {FelisWeb.LayoutView, :root}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
end
```

The [Phoenix source code shows](https://github.com/phoenixframework/phoenix/blob/main/lib/phoenix/controller.ex#L1363) `def protect_from_forgery` is a wrapper around `Plug.CSRFProtection`. This Plug is how the server validates the CSRF token.

See the article [Elixir/Phoenix Security: Introduction to Cross Site Request Forgery (CSRF)](https://paraxial.io/blog/csrf-intro) for more details. 


### 3. Remote Code Execution (RCE)

In the context of web application security, exploiting a remote code execution (RCE) bug involves:

1. The application code accepts user input.

2. An attacker crafts malicious input.

3. The malicious input results in the underlying web server running a command written by an attacker. For example, triggering the `uname -a` command on a Linux server. 

RCE is more severe than XSS and CSRF, because it does not exploit user sessions or require human interaction from the victim. An attacker who can run code on a server can access all sensitive information in the database, steal user credentials, or take over the server and use it to send malicious traffic. 

RCE issues occur in Phoenix by passing user input to:

1. [Elixir's Code module](https://hexdocs.pm/elixir/1.14/Code.html)

2. [EEx eval functions](https://hexdocs.pm/eex/1.14.3/EEx.html)

3. The `:erlang.binary_to_term` function. This is not safe, even with `:erlang.binary_to_term(user_input, [:safe])`. 

See the article [Elixir/Phoenix Security: Remote Code Execution and Serialisation](https://paraxial.io/blog/elixir-rce) for more details. 

*Bug Hunting Tip* - When you are searching for a RCE issue in Potion Shop, you may not find any of these functions in the source code. Check how the dependencies are being used. 


### 4. SQL Injection 

SQL injection is a type of attack against a web application, where some malicious input is parsed by the underlying database, resulting in an unauthorized operation being performed. This can be the disclosure of sensitive data, modification of the database, or deletion of entire tables.

Most Phoenix applications use Ecto, a database wrapper and query generator for Elixir. When used correctly, Ecto prevents SQL injection due to the way queries are constructed. For example, the Ecto query

```elixir
from f in Fruit,
  where: f.quantity >= ^min_quantity
  and f.secret == false
```

where `min_quantity` is untrusted user input, is not vulnerable to SQL injection, because Ecto knows how to safely handle external data. However, Ecto also gives you the power to construct raw SQL queries yourself, a feature that may lead to an SQL injection vulnerability being introduced. 

For example:

```elixir
def e_get_fruit(min_q) do
  q = """
  SELECT f.id, f.name, f.quantity, f.secret
  FROM fruits AS f
  WHERE f.quantity > #{min_q} AND f.secret = FALSE
  """
  {:ok, %{rows: rows}} =
    Ecto.Adapters.SQL.query(Repo, q)
  Enum.map(rows, fn row ->
    [id, name, quantity, secret] = row
    %Fruit{id: id, name: name, quantity: quantity, secret: secret}
  end)
end
```

If `min_q` is user input, this function is vulnerable to SQL injection. 

See the article [Detecting SQL Injection in Phoenix with Sobelow](https://paraxial.io/blog/sql-injection) for more details. 

### 5. Broken Access Control

The standard access control pattern in Phoenix applications involves the `current_user` struct. The book "Programming Phoenix 1.4" gives the following pattern:

```elixir
def call(conn, _opts) do
  user_id = get_session(conn, :user_id)
  user = user_id && Rumbl.Accounts.get_user(user_id) 
  assign(conn, :current_user, user)
end
```

Where the `user_id` is extracted from the user's session. This is the correct way to do access control. Does a user have permission to create a new review? Check the current_user.

However, consider an application where this access control is performed in the user's browser. If the user has permission to create a new review, a form is shown to them. If they do not have permission, the form is not displayed. The key security question to be asking here is, "Is the form submission checked on the backend as well?"

Users and attackers are not limited by front-end access controls. An HTTP request can be defined by the user and sent to the server. 

See the article [Client-Side Enforcement of LiveView Security](https://blog.voltone.net/post/31) for more details. 

## Bug Hunting Methodology

### 1. What is the basic functionality of the application? Is there an API? 

Start by using Potion Shop as a normal user. Perform the following actions:

- Create an account
- Login to your account
- Leave a review on a potion
- Search for potions
- Find the JSON API

### 2. How many endpoints does the router define? 

This can be found with `mix phx.routes`. Read through the router, and notice which controller each route is mapped to. How many pipelines are defined in the router? Where is each pipeline used?

### 3. XSS - How is user input rendered by other users?

As an attacker, how could you get your XSS payload displayed to other users? Check for XSS with the `<script>alert(1)</script>` payload. The XSS issue with Potion Shop is that simple to exploit, no fancy filter evasion tricks needed. 

### 4. CSRF - What are the state changing POST requests? 

Hint: The CSRF issue is not in the authentication routes. 

### 5. SQL injection - How does user input cause an SQL query to run?

The way an incoming HTTP request goes through Potion Shop is roughly:

1. Arrives at the router (router.ex)

2. Dispatched to the appropriate controller function (potion_controller.ex)

3. The controller uses the Carafe.Potions module to perform Ecto queries (potions.ex)

Step through the code in the Potions controller to find the SQLi. 

### 6. RCE - Can user input be transformed into Elixir code?

This is probably the most difficult bug to find. If you have been using Sobelow to find the previous issues, it won't work here because the vulnerable code is in a dependency. 

Hint: Check the "/api" scope.

### 7. Broken access control - Can you use user input to change access control decisions? 

Similar to the SQL injection example, examine the PotionController code to see how user details are being set. 


## Tools

It is recommended you find all of the security issues manually before using automated tools.

[Sobelow](https://github.com/nccgroup/sobelow) - Security-focused static analysis for the Phoenix Framework

[Mix Audit](https://github.com/mirego/mix_audit) - MixAudit provides a mix deps.audit task to scan a project Mix dependencies for known Elixir security vulnerabilities
