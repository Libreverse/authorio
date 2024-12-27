# Authorio

The Authorio plugin turns any Rails-based site into an authentication endpoint for Indieauth.

## Motivation

[IndieAuth](https://indieauth.com/faq) is an authentication protocol that allows you to sign in to a website using a domain name (assuming the web site supports IndieAuth). There are two servers involved in the transaction: the _client_, which is where you're logging in to (authenticating with), and the _authentication endpoint_, which verifies you are who you say you are.

There are several implementations for IndieAuth clients, if you want to support IndieAuth login on your site. But there aren't many useful implementations of the authentication endpoint. Many people work around this by using an IndieAuth service, such as [RelMeAuth](https://indieweb.org/RelMeAuth) which delegates authentication to a third-party site such as Twitter or Facebook.

Authorio allows you to create a truly federated authentication setup, using your own Rails site. By adding Authorio to your site, you can remove any external authentication dependencies and log in using only services you control.

## Installation

### 1. Add the Authorio Gem to your bundle

Add this line to your application's Gemfile:

```ruby
gem 'authorio-updated', git: 'https://github.com/libreverse/authorio-updated.git'
```

And then execute:

```bash
bundle
```

### 2. Install Authorio config files

```bash
rails generate authorio:install
```

### 3. Install Authorio migrations

Authorio needs to add a couple tables to your app's database in order to store (hashed) passwords and access tokens.
You will need to install the migrations and then run them to add these tables

```bash
$ rails authorio:install:migrations
Copied migration 20210703002653_create_authorio_users.authorio.rb from authorio
Copied migration 20210703002654_create_authorio_requests.authorio.rb from authorio
Copied migration 20210710145519_create_authorio_tokens.authorio.rb from authorio

$ rails db:migrate
...
== 20210703002653 CreateAuthorioUsers: migrated (0.0038s) =====================
...
== 20210703002654 CreateAuthorioRequests: migrated (0.0041s) ==================
...
== 20210710145519 CreateAuthorioTokens: migrated (0.0037s) ====================
```

### 4. Install Authorio routes

Add the following line somewhere inside the `Rails.application.routes.draw do` block in your `config/routes.rb` file

```ruby
authorio_routes
```

### 5. Add the Indieauth tags

Somewhere on your home page, add the following to your view template:

```erb
<%= indieauth_tag %>
```

This part of the protocol will tell the IndieAuth client where to redirect for authentication. Note that ideally
you should only place this tag on your home page, and not in a layout that will put it on every page on your site.
(It won't hurt anything but it's redundant to have it in multiple locations)

Although IndieAuth works fine if you put the tag inside a page body, technically it's against the HTML spec to put
`link` tags inside the `<body>`. So the best practice would be to set up the IndieAuth tags as content from your home page.

If you want to set it up that way, then inside the layout where your `HEAD` is defined (typically `application.html.erb`)
you will want to add this line:

```erb
<%= yield :indieauth_link_tags -%>
```

and then from your home page, add

```erb
<% content_for :indieauth_link_tags, indieauth_tag %>
```

This way the IndieAuth tags will appear in your HTML header, but only for your home page.

### 6. Set your initial password

By default, Authorio uses a simple password to authenticate you. This password is hashed and stored in your app
database, which presumably you control.

You are free to customize Authorio to change its authentication scheme however you want, but to get started
quickly you'll want to set up a password for yourself.

```bash
$ rake authorio:password

Enter new password:
Confirm password:
Password set
```

### 7. Precompile assets

Authorio has some of its own assets which, if you're running in a production environment, will need to be precompiled
like your existing assets. Re-run your normal precompilation step to ensure Authorio's assets are in your asset pipeline

```bash
rails assets:precompile
```

Now restart your rails app, and you should be all set!

## Usage

To test your authentication endpoint, find an IndieAuth client you can log in to. A simple test is to try and login
to the [IndieWeb.org website](https://indieweb.org)

- From the home page, click on _Log In_ in the upper right, or visit the [login page](https://sso.indieweb.org/login?url=https%3A%2F%2Findieweb.org%2FMain_Page) directly.
- Enter your site's URL (or if you put the indieauth tag on a page other than your home page, enter that URL)
- You should be then be redirected back to your own site and the Authorio login UI

<p align="center">
<img src="./auth-ui.png" width="400">
</p>

- Enter the password you set up when you installed Authorio. This should redirect you back to the client where you
  will be logged in!

## Configuration

When you installed Authorio it placed a config file in `config/initializers/authorio.rb`. If you want to change
one of the defaults you can uncomment it and specify it here.

### Mount Point

Most Rails engines are mounted via `mount Authorio::Engine, at: mount_point`. But Authorio needs to know its own
mount point (to specify its url in the header tag) so you specify the mount point here. The default `authorio`
should work for everyone.

### Authorization and Token Endpoint

These endpointd are given to servers via discovery. The default values should suffice.

### Token Expiration

If a client asks for an authentication token, the token will be valid for this length of time, after which
you will have to re-authenticate. Longer-lasting
tokens can possibly be a security risk. Default is 4 weeks.

### Local Session Lifetime

Setting this to a time interval will enable you to authenticate without typing in your password. It enables a
"remember me" chekbox on the authentication form. If you check that, then enter your
password once, then your session will be saved in a cookie, and any time you are asked to authenticate again,
you can just click "Sign In" without your password. It can be a security risk if someone else has access to
the machine you are using to login with (eg your laptop). Obviously you don't want to check "remember me"
on a public-access computer. Default is _nil_ (disabled)

### TODO

- [ ] Customizing the authentication view/UI
- [ ] Customizing the authentication method

## User Profile

You can set up your <a href="doc/profile.md">user profile</a> which can be sent to authenticating clients.

## Contributing

Send pull requests to [Authorio on GitHub](https://github.com/reiterate-app/authorio)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
