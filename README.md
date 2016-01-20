# Theme Juice CLI
[![Gem Version](http://img.shields.io/gem/v/theme-juice.svg?style=flat-square)](https://rubygems.org/gems/theme-juice)
[![Travis](https://img.shields.io/travis/ezekg/theme-juice-cli.svg?style=flat-square)](https://travis-ci.org/ezekg/theme-juice-cli)
[![Code Climate](https://img.shields.io/codeclimate/github/ezekg/theme-juice-cli.svg?style=flat-square)](https://codeclimate.com/github/ezekg/theme-juice-cli)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/ezekg/theme-juice-cli.svg?style=flat-square)](https://codeclimate.com/github/ezekg/theme-juice-cli)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ezekg/theme-juice-cli?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

![Theme Juice CLI](demo.gif)

## What is it?
The [Theme Juice CLI](http://themejuice.it), also known as `tj`, helps you create new local WordPress development sites, manage existing sites, and deploy them, all from the command line. It utilizes an [Apache fork](https://github.com/ezekg/theme-juice-vvv) of [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV) for the virtual machine to spin up new development sites in seconds.

Check out [our getting started guide over at SitePoint](http://www.sitepoint.com/introducing-theme-juice-for-local-wordpress-development/), or [view the documentation site](http://themejuice.it).

## What problems does `tj` help solve?
To get the most out of `tj`, it is recommended that you use our [starter template](https://github.com/ezekg/theme-juice-starter). Why? Keep on reading and we'll tell you. `tj` is built on top of tried and true open source libraries such as [Capistrano](http://capistranorb.com/) for deployment, [Vagrant](https://www.vagrantup.com/) for local development, and even a little bit of [WP-CLI](http://wp-cli.org) for database migration. Some of the main pain points `tj` helps solve are:

### 1. Local development
Say goodbye to MAMP! With one command, `tj create`, you can have a new local development site up and running in under a minute. It uses a streamlined fork of VVV (listed above) to create a Vagrant development environment, and lets you create and manage multiple projects within a single virtual machine. It also handles deployments over SSH using Capistrano if you want to move away from FTP (more about that below).

### 2. Multi-environment projects
Oh, multi-environment development! Usually, you would have to ignore your entire `wp-config.php` file and create one for every single stage. These can get out of sync fast. Even worse, the config file actually gets checked into the project repo and so the credentials fluctuate from `dev` to `staging` to `production`. Not good. Not good at all.

Our [starter template](https://github.com/ezekg/theme-juice-starter) uses a `.env` file, and has support for an unlimited number of environments (we generally do `development`, `staging` and `production`). Since these settings are housed in a `.env` file, they are not checked into the repo. That means the codebase is 100% environment agnostic. [The way it should be.](http://12factor.net/)

### 3. Multi-environment deployments
Really. Want to deploy to staging? Set up a staging environment inside of the [`Juicefile`](https://github.com/ezekg/theme-juice-starter/blob/master/Juicefile?ts=2), make sure you can SSH in without a password (remember, best practices here!) and run `tj deploy staging`. Boom, you're done. Make a mistake? Run `tj remote staging rollback`. Crisis averted!

Want to pull the database from your production server to your development install? Run `tj remote production db:pull` and you're good to go; `tj` will automatically handle rewriting any URLs within the database.

How about pushing your development database and your local uploads folder? Run `tj remote production db:push && tj remote production uploads:push` and you're done. [You can even send notifications to your teams Slack channel if you want to!](https://github.com/ezekg/theme-juice-cli#can-i-integrate-my-deployments-with-slack)

## Requirements
**`tj` requires [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to be able to create virtual machines for local development. Please download and install both of these before getting started.** If you plan on using `tj` for deployments, you should also ensure that your `remote` servers have [WP-CLI](http://wp-cli.org/) installed in order for `tj` to be able to handle database migration.

I recommend one of the latest versions of Ruby MRI (2.2, 2.1, 2.0). `tj` requires at least MRI 1.9.3. For the full report, check out the [Travis CI build status](https://travis-ci.org/ezekg/theme-juice-cli), where I test against an array of Ruby interpreters.

I also recommend you set up [SSH-keys for GitHub](https://help.github.com/articles/generating-ssh-keys/). Internally, `tj` uses `git clone` with SSH URLs, [so things might break if you don't have your keys set up properly](#help-it-wont-let-me-git-clone-anything).

## Installation
```
gem install theme-juice
```

## Getting Started

_If you're going to be using [our starter template](https://github.com/ezekg/theme-juice-starter), then I recommend checking out [it's dependencies](https://github.com/ezekg/theme-juice-starter#development-dependencies) before running your first `create`. That way, the build step doesn't fail._

### Initialize the VM
This will install and configure the virtual machine. It will clone the VM into the `vm-path`, install the required Vagrant plugins (such as [Landrush](https://github.com/phinze/landrush), unless disabled) and will also set up port forwarding if you're on OSX.

```
tj init
```

### Create a new project
This will lead you through a series of prompts to set up required project information, such as name, location, template, database info, etc. Using the specified information, it will run the installation process and set up a local development environment, if one hasn't already been set up. It will sync your local project location with the project
location within the VM, so you can run this from anywhere on your local system.

```
tj create
```

#### What happens on your first `create`?
1. `tj` will execute `tj init` if the VM is uninitialized
1. `tj` will clone the selected starter template
1. `tj` will run the starter template's Juicefile `install` command
1. `tj` will create all of the necessary project files, such as:
  * `Customfile` containing DNS and synced folder settings
  * `init-custom.sql` containing database setup
  * `project.conf` containing server settings
  * `wp-cli.local.yml` containing VM paths
1. `tj` will provision the VM to put the new configuration into effect

If you've never used `tj` before, then that last step might take awhile. After that's done, you should be able to access your new project at the specified url. It's that easy!

### Set up an existing project
This sets up an existing local project within the development environment. You will go through a series of prompts to create the necessary files. This command is essentially an alias for `tj create --bare`.

```
tj setup
```

### Remove a project
This will remove a project from your development environment. You will go through a series of prompts to delete a project. This will only remove files that were generated by `tj` i.e. the database setup, DNS setup, and other project configuration files.

It will not touch your local folders that were synced to the VM.

```
tj delete
```

### Deploy a project
This will deploy a project to the passed `<stage>` using [Capistrano](http://capistranorb.com/). Head over to the [docs](http://themejuice.it/deploy) to see all of the available commands. There's a quick getting started section there too for your first deployment!

```
tj deploy <stage>
```

### Want more?
Want to check out all of the various flags and features `tj` offers? Just ask `tj` for help, and you'll be greeted with a nice `man` page full of information about how to use just about everything.

```
tj help
```

Or, you can also check out [themejuice.it](http://themejuice.it) for a pretty website chock-full of the same documentation provided by `tj help`.

## FAQ

1. [Is Windows supported?](#is-windows-supported)
1. [Can I use the original VVV instead of VVV-Apache?](#can-i-use-the-original-vvv-instead-of-vvv-apache)
1. [So, does that mean I can use any Vagrant box?](#so-does-that-mean-i-can-use-any-vagrant-box)
1. [What is a `Customfile`?](#what-is-a-customfile)
1. [What is a `Juicefile`?](#what-is-a-juicefile)
1. [Does `tj` support subdomain multi-sites?](#does-tj-support-subdomain-multi-sites)
1. [Can I access a project from another device (i.e. mobile)?](#can-i-access-a-project-from-another-device-ie-mobile)
1. [Can I add my starter template, ________?](#can-i-add-my-starter-template-________)
1. [Can I integrate my deployments with Slack?](#can-i-integrate-my-deployments-with-slack)
1. [Troubleshooting](#troubleshooting)

### Is Windows supported?
Yes! But, since Windows doesn't support UTF-8 characters inside of the terminal, and is picky about ANSI color codes, you'll probably have to run `tj` with a couple flags.

Something that has worked for me on one of my Windows machines is to run all commands through [git-scm](http://git-scm.com/downloads) with the `--boring --no-landrush` flags. This will disable all unicode characters and colors from being output, and will also disable [Landrush](https://github.com/phinze/landrush), which isn't fully supported on Windows.

To set these globally via the `ENV`, set the following environment variables or run the commands below in your terminal:

```bash
export TJ_BORING=true
export TJ_NO_LANDRUSH=true
```

In addition to that, `tj` uses the [OS gem](https://github.com/rdp/os) to sniff out your OS and it'll adjust a few things accordingly to make sure that nothing breaks.

_I don't regularly develop on Windows, so if you encounter any bugs, please let me know through a **well-documented** issue and I'll try my best to get it resolved._

### Can I use the original VVV instead of VVV-Apache?
Definitely. If you want to use `tj` with Nginx and the [original VVV](https://github.com/Varying-Vagrant-Vagrants/VVV), it's as simple as running `tj` with a few flags:

```bash
tj new --vm-box git@github.com:Varying-Vagrant-Vagrants/VVV.git --nginx
```

To use these permanently, set the appropriate `ENV` variables through your `.bashrc` or similar, i.e. `export TJ_VM_BOX=git@github.com:Varying-Vagrant-Vagrants/VVV.git` and `export TJ_NGINX=true`.

_Note: Before running this, you might want to either choose a new `vm-path`, or destroy any existing VMs inside of your `~/tj-vagrant` directory. If `tj` detects that a VM already installed, it will skip installing the new box._

### So, does that mean I can use any Vagrant box?
Yes and no; in order for `tj` to properly create a project, the Vagrant box needs to follow the same directory structure as VVV, and include a `Customfile`. Here is the required structure that `tj` needs in order to be able to create new projects:

```
├── config/
|  |
|  ├── {apache,nginx}-config/
|  |  |
|  |  ├── sites/
|  |  |  |
|  |  |  ├── site-1.conf
|  |  |  ├── site-2.conf
|  |  |  ..
|  |  ..
|  ├── database/
|  |  |
|  |  ├── init-custom.sql
|  |  ..
|  ..
├── www/
|  |
|  ├── site-1/
|  |  |
|  |  ├── index.php
|  |  ..
|  ├── site-2/
|  |  |
|  |  ├── index.php
|  |  ..
|  ..
├── Customfile
...
```

### What is a `Customfile`?
[It's a file that contains custom rules to add into the main `Vagrantfile`, without actually having to modify it](https://github.com/Varying-Vagrant-Vagrants/VVV/blob/develop/Vagrantfile#L208-L218). This allows us to easily modify the Vagrant box without causing merge conflicts if you were to update the VM source via `git pull`. Every file that `tj` modifies is _meant to be modified_, so at any time you may update your installation of VVV with a simple `git pull` without getting merge conflicts out the wazoo.

### What is a `Juicefile`?
A YAML configuration file called `Juicefile` can be used to store commonly-used build scripts, similar to [npm scripts](https://docs.npmjs.com/misc/scripts). Each command block sequence can be mapped to an individual project's build script, allowing a streamlined set of commands to be used across multiple projects that utilize different tools. If you plan to deploy using `tj`, this file will also house your [deployment configuration](http://themejuice.it/deploy).

Below is the config that comes baked into [our starter template](https://github.com/ezekg/theme-juice-starter):

```yml
#
# Manage command aliases for the current project
#
commands:

  # Run project install scripts
  install:
    - composer install
    - bundle install
    - npm install
    - bower install
    - grunt build

  # Manage build tools
  watch:
    - grunt %args%

  # Manage front-end dependencies
  assets:
    - bower %args%

  # Manage back-end dependencies
  vendor:
    - composer %args%

  # Manage WP installation
  wp:
    - wp ssh --host=vagrant %args%

  # Create a backup of the current database with a nice timestamp
  backup:
    - mkdir -p backup
    - wp ssh --host=vagrant db export backup/$(date +'%Y-%m-%d-%H-%M-%S').sql

  # Package up entire project into a gzipped tar file
  dist:
    - tar -zcvf dist.tar.gz .
```

Each command sequence is run within a single execution, with all `%args%`/`%argN%` being replaced by the passed command. Here's a few example scenarios:
```bash
# Will contain all arguments stitched together by a space
cmd1 %args%
# Will contain each argument mapped to its respective index
cmd2 '%arg1% %arg2% %arg3%'
# Will only map argument 4, while ignoring 1-3
cmd3 "%arg4%"
```

You can specify an unlimited number of commands with an unlimited number of arguments; however, you should be careful with how this is used. Don't go including `sudo rm -rf %arg1%` in a command, while passing `/` as an argument. Keep it simple. These are meant to make your life easier by helping you manage build tools, not to do fancy scripting.

### Does `tj` support subdomain multi-sites?
If you're able to use [Landrush](https://github.com/phinze/landrush) for your DNS, then yes. All subdomains will resolve to their parent domain. Landrush comes pre-installed when you create your first project with `tj`. Having said that, unfortunately, if you're on Windows you'll probably have to manually add the subdomains due to Landrush not being fully supported. If you have the Windows chops, head over there and contribute to Landrush by squashing that bug. I'm sure he would appreciate it!

### Can I access a project from another device (i.e. mobile)?
Yes! Every project created with `tj` will automatically be set up to support using [xip.io](http://xip.io/). If you're using OSX, then everything should work out of the box. If you're not using OSX, then you'll need to point port `80` on your host machine to `8080`; Vagrant cannot do this by default for security reasons.

Once everything is good to go, you can access a project from another device on the same network by going to `<project-name>.<your-hosts-ip-address>.xip.io` e.g. `themejuice.192.168.1.1.xip.io`.

_If you're familiar with forwarding host ports on operating systems other than OSX, check out [this file](https://github.com/ezekg/theme-juice-cli/blob/master/lib/theme-juice/tasks/forward_ports.rb#L34-L51) and make a pull request so that everybody else can benefit from your smarts._

### Can I add my starter template, ________?
Yes! Just update the `TEMPLATES` constant inside [commands/create.rb](https://github.com/ezekg/theme-juice-cli/blob/master/lib/theme-juice/commands/create.rb#L7-L12) and make a pull request. I'll verify that the template includes a `Juicefile` (not required, but preferred to automate build steps), and that everything looks solid. Until then (or if your template is private), just run the command below to clone your template.

```
tj create --template git@your.repo:link/goes-here.git
```

### Can I integrate my deployments with Slack?
Yes, you can integrate deployment notifications with your teams Slack account by adding the following template to your `Juicefile`:

```yml
deployment:
  # ...

  slack:
    url: https://hooks.slack.com/services/your-token
    username: Deploybot
    channel: "#devops"
    emoji: ":rocket:"

  # ...
```

Check out [capistrano-slackify](https://github.com/onthebeach/capistrano-slackify) for more information.

## Troubleshooting

1. [Help! It won't let me `git clone` anything!](#help-it-wont-let-me-git-clone-anything)
1. [What the heck is an `invalid multibyte char (US-ASCII)`?!](#what-the-heck-is-an-invalid-multibyte-char-us-ascii)
1. [Why are my `.dev` domains resolving to `127.0.53.53`?!](#why-are-my-dev-domains-resolving-to-12705353)

### Help! It won't let me `git clone` anything!
If you're hitting issues related to `git clone`, either cloning the VM or a starter template, then you most likely don't have [SSH-keys for GitHub set up correctly](https://help.github.com/articles/error-permission-denied-publickey/). Either go through that article and assure that you can use Git with the `git@` (`ssh://git@`) protocol, or else you can manually run `tj` with the appropriate flags corresponding to the problem-repository, swapping out `git@github.com:` for `https://github.com/`. For example:

```
tj create --template https://github.com/starter-template/repository.git --vm-box https://github.com/vm-box/repository.git
```

The flag duo above replaces the URLs for the starter template and VM box repositories so that they use `https` instead of the `git` protocol.

Or, you can globally update `git` to **always** swap out `git@github.com:` with `https://github.com/` by modifying your `git config` with this command:

```
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

### What the heck is an `invalid multibyte char (US-ASCII)`?!
For one reason or another, your terminal probably doesn't support UTF-8, so it's throwing a fit. Use the `--no-unicode` flag to disable the unicode characters. If the problem still persists, try running it with the `--boring` flag. That should disable all unicode characters and coloring.

```
tj create --no-unicode # Or: tj create --boring
```

### Why are my `.dev` domains resolving to `127.0.53.53`?!
[Google has applied for control of the `.dev` TLD (top level domain)](https://gtldresult.icann.org/application-result/applicationstatus/applicationdetails/1339). To fix it, you'll need to periodically flush your local DNS cache (I'm honestly not entirely sure why). In the future, we'll probably switch to something like `.localhost`. Here are a few commands to flush your cache on OSX:

```bash
# Yosemite:
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Mountain Lion:
sudo discoveryutil mdnsflushcache; sudo discoveryutil udnsflushcaches
```

_Still having issues? [Yell at me!](https://github.com/ezekg/theme-juice-cli/issues)_

## Contributing
1. First, create a _well documented_ [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature/bug fix
1. After getting approval for the new feature, [fork the repository](https://github.com/ezekg/theme-juice-cli/fork)
1. Create a new feature branch (`git checkout -b my-new-feature`)
1. Write tests before pushing your changes, then run Rspec (`rake`)
1. Commit your changes (`git commit -am 'add some feature'`)
1. Push to the new branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## License
Please see [LICENSE](https://github.com/ezekg/theme-juice-cli/blob/master/LICENSE) for licensing details.

## Author
Ezekiel Gabrielse, [@ezekkkg](https://twitter.com/ezekkkg), [http://ezekielg.com](http://ezekielg.com)
