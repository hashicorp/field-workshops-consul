name: AWS-Terraform-Vault-Workshop
class: center,middle,title-slide
count: false
![:scale 80%](images/tfaws.png)
.titletext[
AWS Terraform Workshop]
Build AWS Resources With Infrastructure as Code

???
<!---
AWS Terraform Vault Workshop - Part 1
Terraform for Beginners on AWS

This slide presentation is stored as Markdown code, specifically using the RemarkJS engine to render it. All standard markdown tags are supported, and you can also use some HTML within this document.

If you need to change the look and feel of the slide deck just use the style.css and remark_settings.js files to suit your needs. The content in this file is picked up by index.html when the page is loaded.

HTML comments like this one will show up in the source code, but not in the slides or speaker notes.
--->

Welcome to the beginner's guide to Terraform on AWS. This slide deck is written entirely in Markdown language, which means you can make edits or additions, then submit a pull request to add your changes to the master copy. To make edits to the slide deck simply fork this repository:  

https://github.com/hashicorp/workshops  

edit the Markdown files, and submit a pull request with your changes.

The Markdown content is contained in the docs/terraform and docs/vault directories.

Here are some helpful keyboard shortcuts for the instructor or participant:  

⬆ ⬇ ⬅ ➡ - Navigate back and forth  
P         - Toggle presenter view  
C         - Pop an external window for presentation

Instructor notes are included in plain text, narrative parts are in **bold**. You can use the narrative quotes or change them to suit your own presentation style.

---
name: Link-to-Slide-Deck
The Slide Deck
-------------------------
<br><br><br>
.center[
Follow along on your own computer at this link:

https://bit.ly/hashiaws
=========================
]

---
name: Introductions
Introductions
-------------------------
<br><br><br>
.contents[
* Your Name
* Job Title
* Automation Experience
* Favorite Text Editor
]

???
Use this slide to introduce yourself, give a little bit of your background story, then go around the room and have all your participants introduce themselves.

The favorite text editor question is a good ice breaker, but perhaps more importantly it gives you an immediate gauge of how technical your users are.  

**There are no wrong answers to this question. Unless you say Notepad. Friends don't let friends write code in Notepad.**

**If you don't have a favorite text editor, that's okay! We've brought prebuilt cloud workstations that have Visual Studio Code already preinstalled. VSC is a free programmer's text editor for Amazon, and it has great Terraform support. Most of this workshop will be simply copying and pasting code, so if you're not a developer don't fret. Terraform is easy to learn and fun to work with.**

---
name: Table-of-Contents
class: center,middle
Table of Contents
=========================

.contents[
0. Intro to Terraform & Demo
1. Set Up Your Workstation
2. My First Terraform
3. Terraform In Action: plan, apply, destroy
4. Organizing Your Terraform Code
5. Provision and Configure AWS VMs
6. Manage and Change Infrastructure State
]

???
This workshop should take roughly three hours to complete. It is ideal for a half-day workshop and can be paired with Vault content for a full day of training. The infrastructure participants build during the morning session is used as the lab environment for the afternoon session. So you can do a half day of Terraform and/or Vault, or both of them together.

**Here is our agenda for today's training. We'll be taking breaks after each major section or every hour, whichever comes first. This part of the workshop will take us through lunch break, then we'll cover Vault during the afternoon session.**

---
name: How-to-Provision-a-VM
How to Provision an AWS VM
-------------------------
<br><br><br>

Let's look at a few different ways you could provision a new AWS Virtual Machine. Before we start we'll need to gather some basic information including:

.biglist[
1. Virtual Machine Name
1. Operating System (Image)
1. VM Size
1. Geographical Location
1. Username and Password
]

???
**Has anyone got experience using AWS? How do most of us normally get started? That's right, we log onto the AWS Portal and start clicking around. All of the major cloud providers make this part really easy. You get your account, log on and start clicking buttons. Let's take a peek at what that looks like...**

---
name: AWS-Console-Provision
Method 1: AWS Console (GUI)
-------------------------
![:scale 100%](images/AWS_provision.png)

???
**This should look familiar if you've ever used AWS. You click on Virtual Machines, and you'll see a whole list of different base images you can use to provision your VM. Some of these are provided by Amazon, others are provided by third parties in the marketplace. You either search or browse for the thing you need, and click on it. Easy.**

---
name: AWS-Cloud-Formation
Method 2: AWS CloudFormation
-------------------------
```json
{
...
"Resources" : {
    "EC2Instance" : {
      "Type" : "AWS::EC2::Instance",
      "Properties" : {
        "InstanceType" : { "Ref" : "InstanceType" },
        "SecurityGroups" : [ { "Ref" : "InstanceSecurityGroup" } ],
        "KeyName" : { "Ref" : "KeyName" },
        "ImageId" : { "Fn::FindInMap" : [ "AWSRegionArch2AMI", { "Ref" : "AWS::Region" },
                          { "Fn::FindInMap" : [ "AWSInstanceType2Arch", { "Ref" : "InstanceType" }, "Arch" ] } ] }
      }
    },

    "InstanceSecurityGroup" : {
      "Type" : "AWS::EC2::SecurityGroup",
      "Properties" : {
        "GroupDescription" : "Enable SSH access via port 22",
...
```

CloudFormation templates provide a consistent and reliable way to provision AWS resources. JSON is easy for computers to read, but can be challenging for humans to edit and troubleshoot.

???
**Which brings us to method #2, AWS Resource Manager templates, also known as ARM templates. Have any of you used ARM templates? What's that experience like?**

**ARM templates are written in JSON, which stands for JavaScript Object Notation. It is an open-standard format for transmitting data between computers. And don't get me wrong, JSON is great. If you happen to be a computer. Computers are really good at reading these files full of key-value pairs and lists.**

**The problem is that editing and maintaining huge JSON files is hard for humans. Because JSON is not a programming language, you'll end up writing a lot more lines of complex code that is hard to understand and change.**

**ARM templates - easy for computers to read, hard for humans to troubleshoot and maintain.**

---
name: Provision-with-Terraform-2
Method 3: Provision with Terraform
-------------------------
<br><br><br>
```terraform
resource "aws_virtual_instance" "web" {
  ami                    = "ami-11e84107"
  vpc_security_group_ids = ["sg-e8592829c"]
  instance_type          = "t2.micro"
  key_name               = "MySSHKey"

  tags = {
    Name = "MyFirstVM"
  }
}
```
.center[Example terraform code for building an AWS VM.]

???
**And finally we have option #3, Terraform. Terraform uses a Domain Specific Language, or DSL that is designed to be both human-friendly and machine-readable. This is an example snippet of Terraform code. Now watch as I flip back to the previous slide. Would you rather have to write and maintain this complex and messy JSON, or this simple, compact terraform code?**

Advance back to the previous slide to illustrate the difference between JSON and equivalent Terraform.

---
name: What-is-Terraform
What is Terraform?
-------------------------

![:scale 80%](./images/aws_tf_code.png)

.contents[
* Executable Documentation
* Human and machine readable
* Easy to learn
* Test, share, re-use, automate
* Works on all major cloud providers
]

???
**So what exactly _is_ Terraform? Terraform is the DNA of your hybrid infrastructure. Terraform code is written in HCL, or HashiCorp Config Language. It is the only programming language designed specifically for provisioning infrastructure on any platform.**

**Do any of you have a wiki or set of runbooks that contain provisioning instructions? Think for a moment about that wiki. Now I want you to imagine the date stamp, when was this thing last edited? Let's say it was four years ago. Do you think maybe something could have changed in the past four years?**

**It sounds funny but the truth is your wiki is the obituary of the last known state of your infrastructure. One of the main reasons to use terraform is because it is self-documenting. The code itself explains every step required to build this infrastructure, and therefore it is always up to date.**

---
name: IaC
What is Infrastructure as Code?
-------------------------
<br><br><br>
.biglist[
Infrastructure as Code (IaC) is the process of managing and provisioning cloud infrastructure with machine-readable definition files.

**Think of it as executable documentation.**
]

???
**You might be thinking...why can't I just do this by hand? After all the AWS portal is really easy, and I can just stand up my infrastructure manually. Here's why:**

**Terraform ensures that when you build any type of infrastructure that it gets built correctly every single time, exactly the same way. Let's try a thought experiment. If I gave every single one of you the same build document and asked you to set up a server, I guarantee there will be differences in those machines when you hand them over. They may not be major differences, but over time these can pile up and cause all sorts of uncertainty and issues in your environment.**

**When you require hands on keyboards (or mice), and you start making changes and manual steps on your infrastructure, you've lost the automation battle before it even starts. Even a single manual step can slow down your delivery schedule, and introduce unnecessary risk and change to your environments.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
???
**We sometimes call this philosophy 'Infrastructure as Code', or the practice of expressing all of our provisioning steps as machine-readable code and variables. This is also known as the...**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
]
???
**...codified workflow. When you code-ify all of your manual steps, you'll gain several advantages that allow you to provision faster, with more efficiency, while reducing risk.**


---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
]
???
**One of the main benefits of IaC is the ability to change and update what you built. There are many tools that allow you to provision infrastructure. This is sometimes called 'Day 0' of operations. The real challenge is managing Day N. What happens when you need to alter the infrastructure you built? Maybe you need to destroy or recreate part or all of it? Are you prepared to maintain and care for this infrastructure, without causing any downtime? Because Terraform is a _stateful_ tool, it can help you keep track of your infrastructure and change it with minimal impact.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
* Safely test changes using **`terraform plan`** in dry run mode
]
???
**Do you remember that scene in the movie Jurassic Park, where Samuel L Jackson turns around and says 'hold onto your butts' as he pushes his untested code change into production? Every sysadmin has had that feeling at one time or another. I really hope this works...**

**What if instead we had a way to safely test every change that went into production with a dry run? What would actually happen if I ran this code right now? Terraform comes with a built in dry run mode that allows you to visualize exactly what would happen if you pushed the apply button right now. This is a valuable tool for sysadmins and operations teams who prize stability and uptime.**

**Unexpected changes in the terraform plan output can be investigated _before_ they go into production.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
* Safely test changes using **`terraform plan`** in dry run mode
* Integrate with application code workflows (Git, AWS DevOps, CI/CD tools)
]

???
**Terraform allows you to automate manual processes and build continuous integration or continuous delivery pipelines. Imagine you had a pipeline for creating hardened machine images. Perhaps you have another pipeline for testing your infrastructure build process. These might be chained to other CI/CD application pipelines where the application is deployed into your tested, hardened infrastructure. Think of API driven infrastructure builds, written in a simple langage everybody can use and understand.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
* Safely test changes using **`terraform plan`** in dry run mode
* Integrate with application code workflows (Git, AWS DevOps, CI/CD tools)
* Provide reusable modules for easy sharing and collaboration
]

???
**As you expand your terraform usage, you'll have certain patterns and pieces of your infrastructure that you'd like to re-use. Maybe you want your network security to be set up a certain way, every time. Or perhaps someone wrote a great Terraform config for your web application. Terraform supports custom modules, which are simply packages of pre-built Terraform code that others can use. You can use Terraform modules to avoid repetition, enforce security, and ensure that standards are followed.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
* Safely test changes using **`terraform plan`** in dry run mode
* Integrate with application code workflows (Git, AWS DevOps, CI/CD tools)
* Provide reusable modules for easy sharing and collaboration
* Enforce security policy and organizational standards
]

???
**Terraform Enterprise also supports policy enforcement. You can create a list of dos and do-nots for your users and ensure that people don't build things they shouldn't, or introduce unnecessary risk into your environments. For example, you may have a policy that states that servers should not be exposed to the public internet. Because all your infrastructure is stored as code, you can quickly analyze that code to see if it's breaking any of the rules, preventing the bad behavior *before* the infrastructure gets built.**

---
name: IaC2
Infrastructure as Code Allows Us To...
-------------------------
<br><br>
.biglist[
* Provide a codified workflow to create infrastructure
* Change and update existing infrastructure
* Safely test changes using **`terraform plan`** in dry run mode
* Integrate with application code workflows (Git, AWS DevOps, CI/CD tools)
* Provide reusable modules for easy sharing and collaboration
* Enforce security policy and organizational standards
* Enable collaboration between different teams
]

???
**Now that all your infrastructure is stored in a source code repository, it's very easy for multiple users and teams to collaborate on it. Developer needs a new feature? He or she can easily adjust the source code and send the change back to the operations folks for review. Terraform is a universal language that is understood by both developers and operations teams.**

---
name: IaC-Tools
Other Infrastructure as Code Tools
-------------------------
<br><br>
.center[![:scale 60%](images/infra_tools.png)]

These tools work well for configuring the operating system and application. They are not purpose-built for provisioning cloud infrastructure and platform services.

???
**Some of you might be thinking, that sounds great but what about this other tool that I use? Why shouldn't I just use Ansible since we already have that? Or my people only do Powershell. These are all great tools. But none of them are specifically designed for provisioning tasks.**

**Chef, Puppet and Ansible all work great in the context of your operating system and applications. It's true that you can do some cloud provisioning with each of these tools, but none of them really work as well as Terraform. And conversely, HashiCorp doesn't have a configuration management tool. Terraform works great with all of these tools.**

---
name: Native-Tools
Native Cloud Provisioning Tools
-------------------------
<br><br><br>
.center[![:scale 100%](images/clouds.png)]

Each cloud has its own YAML or JSON based provisioning tool.

Terraform can be used across *all* major cloud providers and VM hypervisors.

???
**Every major cloud provider has their own JSON or YAML based provisioning tool. But all of them are written in YAML or JSON. And if you learn one of these systems, guess what, the others are completely different. Now if you want to have a multi-cloud strategy you have to learn three separate provisioning systems. With Terraform you are using the same language, the same simple syntax on all three of these cloud providers.**

---
name: Config-Hell
.center[![:scale 90%](images/Config_Hell.jpg)]
???
**This is a fun web comic. Those of you who have spent hours poking at a nested JSON template, trying to figure out which layer of curly braces you are in will understand this...**

---
Name: Terraform-vs-JSON
Terraform vs. JSON
-------------------------
<br><br><br>
CloudFormation JSON:
```json
{ "Fn::Join" : [ "delimiter", [ PilotServerName,3 ] ] }
```

Terraform:
```hcl
name = "${var.PilotServerName}3"
```

Terraform code (HCL) is easy to learn and easy to read. It is also 50-70% more compact than an equivalent JSON configuration.

???
1Password did a great blog post illustrating the difference between AWS Cloudformation (JSON) and Terraform.

https://blog.1password.com/terraforming-1password/

1Password were able to move their entire production infrastructure to Terraform in a few short weeks. Now they can tear down and completely rebuild their production environment in a matter of hours.

---
Name: Why-Terraform-on-AWS
Why Terraform on AWS?
-------------------------

.contents[
* Supports multi-cloud & hybrid infrastructure
]

???
**Why specifcially should you use Terraform on AWS? The first reason is that Terraform supports your hybrid or multi-cloud strategy. If you need to build some infrastructure on-prem, and some in AWS, Terraform is a natural fit. Your technical staff only has to learn a single language to be able to provision in either environment.**

---
Name: Why-Terraform-on-AWS
Why Terraform on AWS?
-------------------------

.contents[
* Supports multi-cloud & hybrid infrastructure
* Migrate from other cloud providers
]

???
**Terraform is also great for migrating between cloud providers. Let's say you wanted to move some workloads from AWS to AWS. The code changes in Terraform would be much easier to implement than they would via ARM templates. I was able to migrate a simple demo application from one cloud to another in a few short hours, because there was almost no learning curve. Terraform code looks the same no matter where you run it.**

---
Name: Why-Terraform-on-AWS
Why Terraform on AWS?
-------------------------

.contents[
* Supports multi-cloud & hybrid infrastructure
* Migrate from other cloud providers
* Increase provisioning speed
]

???
**It's not unusual to see provisioning times drop from days or weeks to hours or minutes when users adopt Terraform. Ineffective manual steps and change approvals can be replaced with fast code pipelines that have rigorous testing and security built right in. Now instead of waiting for days for a change request to be approved, users can self-provision their infrastructure without bottlenecks or slow approval processes.**

---
Name: Why-Terraform-on-AWS
Why Terraform on AWS?
-------------------------

.contents[
* Supports multi-cloud & hybrid infrastructure
* Migrate from other cloud providers
* Increase provisioning speed
* Improve efficiency
]

???
**Have you heard the saying 'measure twice, cut once?'? Terraform forces your operations teams to be disciplined and consistent with every single build. Have a change or setting that was overlooked during the build? Now you can immediately correct that mistake inside the code, so that a particular step never gets missed again. All future builds will contain the change. This can also improve relations between developers and operations, because the contract is clear. What gets built is always defined in the code, and never left to guesswork or manual processes.**

---
Name: Why-Terraform-on-AWS
Why Terraform on AWS?
-------------------------

.contents[
* Supports multi-cloud & hybrid infrastructure
* Migrate from other cloud providers
* Increase provisioning speed
* Improve efficiency
* Reduce risk
]

???
**Every modern IT organization has to deal with risk. It's a balancing act between security and usability. You can make it so secure nobody can use it, or on the other end you have a free for all where users can do whatever they want, but are putting the entire cloud account in jeopardy due to risky behavior. Terraform allows you to reduce risk by abstracting your users away from the web UI or API. Instead we provide a safe, auditable abstraction layer that lets users get their work done in a secure and safe way, that doesn't grant unnecessary privileged access.**

---
name: Live-Demo
class: center,middle
Live Demo
=========================
???
**Let's do a short demo! I'm going to show you how easy it can be to provision infrastructure in AWS. I'll do the demo on one of the workstations that you'll be using for this training.**

NOTE: We tested this in the eastus region and it took around five minutes to build the lab environment. You'll probably want to pre-bake your demo environment and just show the terraform output and Vault server.

Here is some sample dialog you can use for the demo. Keep it short and sweet. Nobody wants a long boring lecture.

**This is a workstation just like the ones you'll be using for today's workshops. I'm going to run a terraform apply command to build out the lab environment. We're actually cheating a little bit here, as we prebaked most of the environment before class to save us some time. Just like your favorite cooking show!**

**You can see the results of the terraform run here in my terminal window. These outputs are showing me the URL of the Vault server I just built. And if we pop over here to the AWS portal you'll see all of the different parts of my lab environment.**

**This is Infrastructure as code. By the end of today's training you'll be able to create your own infrastructure using Terraform.**

**During the morning workshop session each of you will be building a Vault server that you will use after lunch, during the Vault training.**

---
name: Chapter-1
class: center,middle
.section[
Chapter 1  
Set Up Your Workstation
]


---
name: workstation-setup-0
Choose Your Workstation
-------------------------

Your instructor will provide you with:

* A cloud based Windows workstation with all our tools pre-installed.

???
Instructor Note: If your users want to bring their own AWS accounts, they can do all the exercises in AWS Cloudshell. Or if you are able to spin up accounts inside a training account and provide them to your students that's fine too. Otherwise we recommend using the AWS Dev/Test prebuilt workstations described in the instructor notes in this repo.

---
name: workstation-setup-1
Log Onto Your Workstation
-------------------------

Your instructor will provide you with a workstation URL.

Use Remote Desktop (RDP) to access your workstation.

Your instructor will provide the username and password.

???
Note to the instructor - outbound access on TCP port 3389 is required for this to work. Always have someone at the client check that they can access a test workstation *before* you go on site. You don't want to show up for training and find out that RDP access is blocked from the network you're using.

RDP is installed by default on almost all Windows corporate PCs and laptops. If your students are on Mac they can download the official Amazon RDP client from the app store.

---
name: workstation-setup-2
Run the setup_aws.ps1 script
-------------------------
<br><br>
.center[![:scale 50%](images/run_setup.png)]

Right click on the file called 'setup' on your desktop and select 'Run with Powershell'. Type Y for Yes when it asks about changing your execution policy.

**WARNING:** Do not skip this step. It is required to set up your connection to AWS Cloud.

???
If anyone is curious what this powershell script does, it's disabling windows line endings for git clone. It also fetches dynamic AWS credentials that are good for 8 hours.

**This handy script does some setup and fetches dynamic AWS credentials from our training Vault server. Right click on the setup.ps1 file and select the "Run with Powershell" option. It may take a minute or two to finish.**

---
name: workstation-setup-2a
Run the setup.ps1 script
-------------------------
<br><br>
.center[![:scale 80%](images/ready_to_terraform.png)]

You should see this banner if the script ran successfully.

---
name: workstation-setup-3
Open Visual Studio Code
-------------------------
.center[![:scale 70%](images/set_colors_and_icons.png)]

Click the little gear icon in the lower left corner. You can adjust your Color Theme, File Icon Theme, and other settings such as Font Size. Choose a color theme and font size that are comfortable for you.

???
I like to demo this part for the students. My personal favorites are Dracula and vscode-icons. Be sure and reload if you add any new extensions or themes. Remember that some of these folks have never used Visual Studio Code before. Know where the font, color, and icon settings are and show them how to change these.

**Let's take a moment to move in and get comfortable. You can click on this little gear icon in the lower left corner to access your settings. Pick a color theme and font size that are easy on the eyes. You can also adjust your icons. I like the vscode-icons set, which has an icon for almost every type of file you can imagine.**

---
name: workstation-setup-3a
Warning Message
-------------------------
<br><br>
.center[![:scale 70%](images/renderer.png)]

If you see this warning message just select 'Yes'. Visual Studio Code works better with the DOM-based renderer on remote workstations.

???
The reason for this is VSC wants to use your graphics card on your local laptop if its available. This doesn't work so well in the cloud.

---
name: workstation-setup-4
Install the Terraform Extension
-------------------------
.center[![:scale 70%](images/install_terraform_extension.png)]

Click the box shaped icon on the left side menu. This brings you to the Extensions Marketplace. Search for Terraform. Install the first one on the list. Click the 'Reload' button once it is done installing.

???
**The terraform extension gives you syntax highlighting, code completion, and the ability to run terraform commands right from the command palette.**

---
name: workstation-setup-5
Open the Integrated Terminal
-------------------------
.center[![:scale 70%](images/open_terminal.png)]

Open the integrated VSC terminal using the menu or keyboard shortcut. You'll be asked to choose a default shell the first time you do this. Select Powershell as your default shell. You can change this later in your settings if you wish.

???
I've seen this popup sometimes take two tries to save properly. It might be a bug. In any case it shouldn't matter because the default is Powershell which is what we want.

---
name: workstation-setup-6
Clone the Training Repo
-------------------------
Run the following commands to clone the training repository from GitHub. Run the Windows workstation commands if you have a cloud workstation provided by your instructor. Run the Cloudshell commands if you're using AWS Cloudshell in a browser window.

Windows Workstation Commands
```powershell
cd ~/Desktop
git clone https://github.com/hashicorp/workshops
cd workshops/aws
code -r .
```

???
**This git command is copying a remote repository full of Terraform code onto your workstation. After that we change directories into the repo, and reload our text editor with the current folder opened. Visual Studio Code has a built in file browser which is essential for keeping track of large Terraform projects.**

---
name: workstation-setup-7
Get to Know Visual Studio Code
-------------------------
.center[![:scale 70%](images/vsc_tour.png)]

* Left side: File browser, search, version control & more.
* Lower right: Integrated terminal. Run all commands here.
* Upper right: Open and edit multiple files in tabs.

???
**This is your learning environment. You can do everything from within Visual Studio Code. On the left is your file browser, for managing, renaming, moving or opening files. On the upper right we have our text editor. And down here is the terminal, this is where we'll be running our terraform commands.**

---
name: workstation-setup-8
Explore the Repository
-------------------------
.center[![:scale 70%](images/terraform_config_files.png)]

Terraform configuration files always end in either a `.tf` or `.tfvars` extension. These files are marked with the purple Terraform icon if you are using the vscode-icons set.

???
This is a good time to explore the VSC text editor a bit. Show your students that you can do almost everything from within the editor. You can expand and collapse the file browser. Show what each icon on the left side of the GUI does. You can also point out that the terminal can easily be maximized or minimized.

---
name: workstation-setup-10
Verify That Terraform is Installed
-------------------------
<br>
Run the terraform --version command:

```powershell
terraform --version
```

You should see the following output (version number may vary):

```powershell
PS> terraform --version
Terraform v0.12.1
```

???
**We've preinstalled terraform on your workstation for you. You can also download terraform and install it on your own laptop or desktop computer if you wish. Terraform is shipped as a single zip file. You download it, unzip it, and put it somewhere you can run it. Easy.**

---
name: chapter-1-review
📝 Chapter 1 Review
-------------------------
.contents[
In this chapter we:
* Logged onto your workstation
* Configured Visual Studio Code
* Cloned the training git repository
* Opened VSC in the training folder
]

---
name: Chapter-2
class: center,middle
.section[
Chapter 2  
My First Terraform
]

???
**Now that you have terraform installed and working with AWS, we can do a few dry runs before building real infrastructure. Follow along carefully, copying and pasting the commands on each slide into your terminal as we go.**

---
name: terraform-help
Run Terraform Help
-------------------------
Run the **`terraform help`** command in your Terminal:

Command:
```powershell
terraform help
```

Output:
```tex
Usage: terraform [-version] [-help] <command> [args]

  The available commands for execution are listed below.
  The most common, useful commands are shown first, followed by
  less common or more advanced commands. If you're just getting
  started with Terraform, stick with the common commands. For the
  other commands, please read the help and docs before usage.

  Common commands:
      plan               Generate and show an execution plan
      graph              Create a visual graph of Terraform resources
      init               Initialize a Terraform working directory
      console            Interactive console for Terraform interpolations
      fmt                Rewrites config files to canonical format
      get                Download and install modules for the configuration
      ...
```
???
**This is a good command to know. Terraform help will reveal all the available subcommands.**

---
name: terraform-init
Run Terraform Init
-------------------------
Run the **`terraform init`** command in your Terminal:

Command:
```powershell
terraform init
```

Output:
```tex
Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.17.0)...

Terraform has been successfully initialized!
```

Terraform fetches any required providers and modules and stores them in the .terraform directory. You can take a peek inside that directory where you'll see the plugins folder.

???
**Terraform has an extendible architecture. You download the core program, terraform, then it fetches plugins and modules that are required for your code.**

---
name: terraform-plan
Run Terraform Plan
-------------------------
Run the **`terraform plan`** command in your Terminal. Terraform will prompt you to set the required prefix variable. Enter your name in all lowercase letters.

Command:
```powershell
terraform plan
```

Output:
```tex
var.prefix
  This prefix will be included in the name of most resources.

* Enter a value: bugsbunny

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
```

???
**`terraform plan` is a dry run command. We're not actually building anything yet, Terraform is just telling is what it would do if we ran it for real.**

**If you're curious, how are we authenticating to AWS? We saved some AWS credentials on your workstation as environment variables when we ran the setup.ps1 script. You can also use Terraform directly from AWS cloudshell. Terraform is preinstalled in cloudshell and doesn't require any authentication or special configuration.**

---
name: terraform-plan-2
Run Terraform Plan
-------------------------
<br><br>
When you run **`terraform plan`** and enter your name, you should see output that looks like this:

```tex
Terraform will perform the following actions:

  + aws_vpc.workshop
      id:                               <computed>
      arn:                              <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.0.0.0/16"
      default_network_acl_id:           <computed>


Plan: 1 to add, 0 to change, 0 to destroy.
```

We are not actually building anything yet. This is just a dry run, showing us what would happen if we applied our change.

---
name: terraform-plan-3
Optional - Save Your Plan
-------------------------
<br><br><br>
You may have noticed this output when you ran **`terraform plan`**:

```tex
Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

If you specify the -out parameter, you can save your Terraform plan in a file and run it later.

???
Why might you want to do this? Maybe you have a maintenance window and can only implement changes on Friday evening. But you'd like to do the dry run on Friday afternoon. So you run the plan, have it approved, and save it for deployment later that night.

---
name: set-prefix
Set the Prefix Variable
-------------------------
Rename the **terraform.tfvars.example** file to **terraform.tfvars**.  

Change where it says "yourname" to your own name. No spaces or special characters please. **Keep it all lowercase.** Save the file.

```tex
# Rename or copy this file to terraform.tfvars
# Prefix must be all lowercase letters, no symbols please.

*prefix = "yourname"
```

Now you will no longer be prompted to enter your prefix variable when you run terraform commands.

The **terraform.tfvars** file is your own personal settings file. You can use it to set or override any of the default variables in the variables.tf file.

**Everyone must choose a unique prefix. 5-12 characters. All lowercase or numbers.**

???
**Let's go ahead and set this variable in a file so we don't have to type it in every time we run terraform commands. You're going to simply rename the terraform.tfvars.example file to terraform.tfvars. Terraform knows to look for files that end in .tf or .tfvars. You can right click the file right inside VSC to rename it. You may put any text you like here but be sure and avoid very common names and words, or add a number to the end to guarantee it is unique.**

NOTE TO INSTRUCTOR: If students have a very common name, they should add a number to the end of it to guarantee that it is available. The default AWS public 'cloudapp' DNS zone is a global namespace. If your student enters a very common word here, there's a chance it could be taken already. This will cause the Terraform run to fail.

---
name: defining-variables
Where are Variables Defined?
-------------------------
Open up the **variables.tf** file and you can see all of the defined variables. Note that some of them have default settings. If you omit the default, the user will be prompted to enter a value.

Here we are *declaring* all the variables that we intend to use in our Terraform code.

```tex
variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  description = "The region where the virtual network is created."
  default     = "us-east-1"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}
```

???
**If you're curious where all these variables are defined, you can see them all in the _variables.tf_ file. Here we are simply defining all the available settings, and optionally declaring some default values. These defaults are what terraform will use if your user doesn't override them with their own settings.**

Q. Where could you override these defaults?  
A. In the terraform.tfvars file, or optionally on the command line or via environment variables. The most common approach is to use a tfvars file.

---
name: chapter-2-lab
.center[.lab-header[👩‍💻 Lab Exercise 2: Set a Variable]]

Choose the AWS location nearest to you and set the 'region' variable. You can find a list of AWS regions here:

https://docs.aws.amazon.com/general/latest/gr/rande.html

Examples:
```
us-east-2	  - US East (Ohio)
us-east-1	  - US East (N. Virginia)
us-west-1	  - US West (N. California)
us-west-2	  - US West (Oregon)
```

???
Have the students do this one on their own. They can choose any region, please let us know if you find any regions that do not support the VM type we use in this workshop.

---
name: chapter-2-lab-answer
.center[.lab-header[👩‍💻 Lab Exercise 2: Solution]]
<br><br><br>
Your **terraform.tfvars** file should now look similar to this:

```tex
# Rename or copy this file to terraform.tfvars
# Prefix must be all lowercase letters, no symbols please.

prefix = "yourname"
region = "us-east-1"
```

If you wish you can run **`terraform plan`** again to see a different result. Notice how your location setting has overridden the default setting.

---
name: chapter-2-review
📝 Chapter 2 Review
-------------------------
.contents[
In this chapter we:
* Used the **`terraform init`** command
* Ran the **`terraform plan`** command
* Learned about variables
* Set our location and prefix
]

---
name: Chapter-3
class: center,middle
.section[
Chapter 3  
terraform plan, apply and destroy
]

???
**In this chapter we'll actually build real infrastructure using our sample code.**

---
name: main.tf
Terraform Comments
-------------------------
<br><br>
Open the main.tf file in the VSC file browser. You'll notice that most of the file is full of comments. There are two types of comments:

Line Comments begin with an octothorpe<sup>*</sup>, or pound symbol: #
```hcl
# This is a line comment.
```

Block comments are contained between /\* and \*/ symbols.
```tex
/* This is a block comment.
Block comments can span multiple lines.
The comment ends with this symbol: */
```
<br><br>
.smalltext[
\* Yes, it really is called an [octothorpe](https://www.merriam-webster.com/dictionary/octothorpe).
]

---
name: anatomy-of-a-resource
Anatomy of a Resource
-------------------------
Every terraform resource is structured exactly the same way.

.center[![:scale 80%](images/resource_anatomy.png)]

*resource* = top level keyword

*type* = this is the name of the resource. The first part tells you which provider it belongs to. Example: `aws_instance`. This means the provider is AWS and the specific type of resource is a virtual machine.

*name* = arbitrary name to refer to this resource. Used internally by terraform. This field *cannot* be a variable.

???
Everything else you want to configure within the resource is going to be sandwiched between the curly braces. These can include strings, lists, and maps.

---
name: provider-block
Terraform Provider Configuration
-------------------------
<br><br><br>
Open up the main.tf file in Visual Studio Code and you'll see the provider block.

You can manually configure which version(s) of a provider you would like to use. If you leave this option out, Terraform will default to the latest available version of the provider.

```hcl
provider "aws" {
  version = "~> 2.0"
}
```

???
**Here we have pinned the provider version to 1.30.1. We recommend pinning your provider versions, especially in production.**

---
name: resources-building-blocks
Resources - Terraform Building Blocks
-------------------------
<br><br><br>
Scroll down a little further and find the first resource in the main.tf file on lines 19-24. These lines are already uncommented for you.

You can toggle comments with the _Edit > Toggle Line Comment_ menu, or by simply highlighting some text and pressing `CTRL-/`.

```hcl
resource "aws_vpc" "workshop" {
  cidr_block       = "${var.address_space}"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}
```

???
**Try commenting out this code, then uncommenting it. This is the easy way to write code. Just highlight, uncomment, save the file.**

**Resources are the smallest building blocks of Terraform. Think of them as declarative statements about what you want to build. Save the main.tf file.**

**Note that the resource contains references to the two variables we set in the previous chapter, location and prefix. These will be replaced when we run terraform commands. Variables are always enclosed in a dollar sign and curly braces.**

I like to flip over to my own workstation and actually show them how to do this. If you run your own workstation in a separate virtual desktop or window, you can easily flip back and forth between slides and live code.

---
name: terraform-plan
I Love It When a Plan Comes Together
-------------------------
Run the **`terraform plan`** command and observe the output:

Command:
```powershell
terraform plan
```

Output:
```tex
------------------------------------------------------------------------
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.workshop
      id:                               <computed>
      arn:                              <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.0.0.0/16"
      ....

Plan: 1 to add, 0 to change, 0 to destroy.
------------------------------------------------------------------------
```

???
**Terraform plan is a dry run. It gives you a chance to have other people review and approve your changes before you apply them.**

---
name: terraform-apply
Terraform Apply
-------------------------
Run the **`terraform apply`** command to execute the code and build a resource group. Type 'yes' when it prompts you to continue.

Command:
```powershell
terraform apply
```

Output:
```tex
...
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
  Enter a value: yes

aws_vpc.workshop: Creating...
  arn:                              "" => "<computed>"
  assign_generated_ipv6_cidr_block: "" => "false"
  cidr_block:                       "" => "10.0.0.0/16"
  ....
aws_vpc.workshop: Creation complete after 8s (ID: vpc-0cf22f733192....)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---
name: terraform-plan-again
Terraform Plan - Repeat
-------------------------
Run the **`terraform plan`** command again and see what happens.

Command:
```powershell
terraform plan
```

Output:
```tex
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_vpc.workshop: Refreshing state... (ID: vpc-0cf22f733192....)

------------------------------------------------------------------------

*No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

???
Terraform is sometimes called idempotent. This means it keeps track of what you built, and if something is already in the correct state Terraform will leave it alone.

---
name: terraform-destroy
Terraform Destroy
-------------------------
Run the **`terraform destroy`** command to delete your resource group.

Command:
```powershell
terraform destroy
```

Output:
```tex
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

Destroy complete! Resources: 0 destroyed.
```

???
**Terraform can just as easily destroy infrastructure as create it. With great power comes great responsibility!**

---
name: we-can-rebuild-him
We Can Rebuild Him
-------------------------
This time you can skip straight to **`terraform apply`**. Use the **`-auto-approve`** flag this time to avoid having to type 'yes'.

Command:
```powershell
terraform apply -auto-approve
```

Output:
```tex
aws_vpc.workshop: Creating...
  arn:                              "" => "<computed>"
  assign_generated_ipv6_cidr_block: "" => "false"
  cidr_block:                       "" => "10.0.0.0/16"
  ....
aws_vpc.workshop: Creation complete after 8s (ID: vpc-0cf22f733192....)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

???
The phrase "We can rebuild him. We have the technology." comes from 1970s TV show, The Six Million Dollar Man. https://www.youtube.com/watch?v=0CPJ-AbCsT8#t=2m00s

---
name: chapter-3-lab
.center[.lab-header[👩🏼‍💻 Lab Exercise 3b: Add a Tag]]
<br><br><br>
Read the documentation for the `aws_vpc` resource and learn how to add tags to the vpc:

https://www.terraform.io/docs/providers/aws/r/vpc.html

Edit your main.tf file and add a tag to the resource. Set the name of the tag to 'environment' and the value to 'Production'.

???
Don't just give the answer away here. Let people struggle a little bit and try to actually read the documentation. You can literally copy the example right from the docs into your code. Wait a few minutes until everyone's had a chance to try and do this on their own.

---
name: chapter-3-lab-answer
.center[.lab-header[👩🏼‍💻 Lab Exercise 3b: Solution]]
<br><br>
Adding and removing tags is a non-destructive action, therefore Terraform is able to make these changes in-place, without destroying your resource group. Your main.tf file should look like this:

```terraform
resource "aws_vpc" "workshop" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags = {
    Name = "${var.prefix}-workshop"
    environment = "Production"
  }
}
```

Note how the tag is added by modifying the existing resource:
```tex
Aaws_vpc.workshop: Modifying... (ID: vpc-01a5c1289101109b6)
  tags.%:           "1" => "2"
  tags.environment: "" => "Production"
aws_vpc.workshop: Modifications complete after 6s (ID: vpc-01a5c1289101109b6)
```

???
Some resources can be non-destructively changed in place. Ask your class what they think some of those resources might be? Good examples are tags and security group rules.

---
name: add-virtual-network
Add a Subnet
-------------------------
<br><br>
Let's add a subnet. Scroll down in the main.tf file until you find the `aws_subnet` resource. Uncomment it and save the file.

```terraform
resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}
```
Note the syntax for ensuring that this subnet is placed into the resource group we created earlier.

???
Hop over to your own workstation and regenerate the terraform graph. Point out that we now have a Virtual Network, that depends on the resource group. How did Terraform know these things are connected?

---
name: dependency-mapping
Terraform Dependency Mapping
-------------------------
<br><br>
Terraform can automatically keep track of dependencies for you. Let's take a look at the two resources in our main.tf file. Note the highlighted line in the aws_subnet resource. This is how we tell one resource to refer to another in terraform.

```terraform
resource "aws_vpc" "workshop" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}
resource "aws_subnet" "subnet" {
*  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}
```

---
name: terraform-apply-again
Terraform Apply
-------------------------
Run the **`terraform apply`** command again to build the virtual network.

Command:
```powershell
terraform apply -auto-approve
```

Output:
```tex
aws_vpc.workshop: Refreshing state... (ID: vpc-01a5c1289101109b6)
aws_subnet.subnet: Creating...
  arn:                             "" => "<computed>"
  assign_ipv6_address_on_creation: "" => "false"
  availability_zone:               "" => "<computed>"
  availability_zone_id:            "" => "<computed>"
  cidr_block:                      "" => "10.0.1.0/24"
  ipv6_cidr_block:                 "" => "<computed>"
  ...
  tags.%:                          "" => "1"
  tags.Name:                       "" => "bugsbunny-workshop-subnet"
  vpc_id:                          "" => "vpc-01a5c1289101109b6"
aws_subnet.subnet: Creation complete after 3s (ID: subnet-0604cc348237cc9be)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

???
The auto-approve flag is so we don't have to type 'yes' every time we run terraform.

---
name: chapter-3c-lab
.center[.lab-header[👩🏽‍💻 Lab Exercise 3c: Build the Vault Lab]]
<br><br><br>
Go through the rest of the **main.tf** file and uncomment all of the terraform resources.

Alternatively, you can copy all of the contents of the **main.tf.completed** file into your **main.tf** file. Just make sure you overwrite the entire file and save it.

Run **`terraform apply`** again to build out the rest of your lab environment.

???
Note the dependency in the `data` block that forces terraform to wait until the Virtual Machine is fully provisioned and has a Public IP address before proceeding. Without that `depends_on` parameter the run may sometimes fail. You don't have to highlight this or explain it. This is for the instructor just in case someone asks. Normally it's best to allow Terraform to discover all dependencies automatically.

NOTE: It will take up to five minutes to build out the lab environment. This is a good place to take a break, or have some time for open discussion and questions.

---
name: chapter-3c-lab-answer
.center[.lab-header[👩🏽‍💻 Lab Exercise 3c: Solution]]
<br><br>
If you copied all the code over from **main.tf.completed** into **main.tf**, it should look like this (comments have been removed for brevity):

```terraform
resource "aws_vpc" "workshop" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}
resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}
...
```

---
name: chapter-3-review
📝 Chapter 3 Review
-------------------------
.contents[
In this chapter we:
* Learned about Terraform resources
* Ran terraform plan, graph, apply and destroy
* Learned about dependencies
* Built the lab environment
* Viewed a graph of the lab
]

---
name: Chapter-4
class: center,middle
.section[
Chapter 4  
Organizing Your Terraform Code
]

---
name: organizing-your-terraform
Organize Your Terraform Code
-------------------------
.center[![:scale 85%](images/terraform_config_files.png)]
You should have three files that end in the \*.tf extension on your workstation. The convention is to have a main.tf, variables.tf, and outputs.tf. You may add more tf files if you wish.

---
name: terraform-main
The Main File
-------------------------
The first file is called main.tf. This is where you normally store your terraform code. With larger, more complex infrastructure you might break this up across several files.

```powershell
# This is the main.tf file.
resource "aws_vpc" "workshop" {
  cidr_block       = "${var.address_space}"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}
resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "${var.subnet_prefix}"

  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}
...
```

???
**We've removed all the comments from this code so it will fit on the slide.**

---
name: terraform-variables
The Variables File
-------------------------
The second file is called variables.tf. This is where you define your variables and optionally set some defaults.

```powershell
variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  description = "The region of aws to use"
  default     = "us-east-1"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}
```

---
name: terraform-outputs
The Outputs File
-------------------------
The outputs file is where you configure any messages or data you want to show at the end of a terraform apply.

```terraform
output "Vault_Server_URL" {
  value = "http://${aws_instance.vault-server.public_ip}:8200"
}

output "MySQL_Server_FQDN" {
  value = "${aws_db_instance.vault-demo.address}"
}

output "Instructions" {
  value = <<EOF

##############################################################################
# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.
##############################################################################

ssh ubuntu@${aws_instance.vault-server.public_ip}

EOF
}
```

???
**This bit here with the EOF is an example of a HEREDOC. It allows you store multi-line text in an output.**

---
name: terraform-outputs
The Outputs File
-------------------------
Open up the outputs.tf file in Visual Studio Code. Uncomment all of the outputs. Save the file.

```terraform
output "Vault_Server_URL" {
  value = "http://${aws_instance.vault-server.public_ip}:8200"
}

output "MySQL_Server_FQDN" {
  value = "${aws_db_instance.vault-demo.address}"
}

output "Instructions" {
  value = <<EOF

##############################################################################
# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.
##############################################################################

ssh ubuntu@${aws_instance.vault-server.public_ip}

EOF
}
```
???
The bit with EOF is called a heredoc. This is how you add multiple lines or a paragraph of text to your outputs.

---
name: terraform-refresh
Terraform Refresh
-------------------------
Run the **`terraform refresh`** command again to show the outputs. You will also see these outputs every time you run **`terraform apply`**.

Command:
```powershell
terraform refresh
```

Output:
```tex
Outputs:

Instructions =
##############################################################################
# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.
##############################################################################

ssh ubuntu@IPADDRESS

MySQL_Server_FQDN = terraform-20190627032621775400000001.coydleaeb0pt.us-east-1.rds.amazonaws.com
Vault_Server_URL = http://IPADDRESS:8200
```

---
name: terraform-output
Terraform Output
-------------------------
If you just want to see the outputs again, use the **`terraform output`** subcommand.

Command:
```powershell
terraform output
```

Output:
```tex
Outputs:

Instructions =
##############################################################################
# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.
##############################################################################

ssh ubuntu@IPADDRESS

MySQL_Server_FQDN = terraform-20190627032621775400000001.coydleaeb0pt.us-east-1.rds.amazonaws.com
Vault_Server_URL = http://IPADDRESS:8200
```

---
name: terraform-output-2
Terraform Output - Single Value
-------------------------
<br><br><br><br>
If you only want to fetch one of the outputs, use this syntax:

Command:
```powershell
terraform output Vault_Server_URL
```

Output:
```tex
http://IPADDRESS:8200
```

???
**The name of the variable here is CaSe Sensitive. Make sure you copy it exactly.**

---
name: chapter-4a-lab
.center[.lab-header[👩🏿‍💻 Lab Exercise 4a: Break main.tf Down]]
<br><br><br><br>
Take the aws_instance resource out of main.tf and put it into its own file called **vm.tf**. Save both files. Run **`terraform apply`** again. What happens?

???
**Don't forget to take the config resource out of main.tf when you copy it into vm.tf. Otherwise you'll have two resources of the same type, with the same name, which causes an error.**

---
name: chapter-4a-lab-answer
.center[.lab-header[👩🏿‍💻 Lab Exercise 4a: Solution]]
<br><br><br><br>
If you break a large *.tf file down into smaller ones, Terraform doesn't mind. It simply crawls through the directory looking for anything that ends in a .tf extension. All resources in all tf files will be compiled together onto the resource graph before the apply is run.

If you want to exclude some tf files from being run, simply rename them with a different extension or move them into another directory.

???
Some extra notes:

Terraform will *not* crawl into subdirectories looking for tf files. There's also no way to tell terraform which specific tf files to run or not run. The default behavior is to parse any file ending with the .tf or .tfvars extensions in the current directory.

---
name: chapter-4b-lab
.center[.lab-header[👩‍🔬 Lab Exercise 4b: Format Your Code]]

<br><br><br>
Terraform comes with a built-in code formatting command, **`terraform fmt`**. Add some extra white space and lines to your Terraform code, save the file(s), then run this command in your terminal:

```bash
terraform fmt
```
---
name: chapter-4b-lab-answer
.center[.lab-header[👩‍🔬 Lab Exercise 4b: Solution]]

<br><br><br><br>
When you run the **`terraform fmt`** command your code is automatically formatted according to recommended standards. This ensures that your code is always neat and tidy, and eliminates unnecessary code versions caused by empty spaces.

???
Have your students play around with the **`terraform fmt`** command for a bit.

---
name: chapter-4-review
📝 Chapter 4 Review
-------------------------
.contents[
In this chapter we:
* Looked at main.tf, variables.tf and outputs.tf
* Enabled some outputs in our code
* Refactored our main.tf into smaller parts
* Learned the **`terraform fmt`** command
]

---
name: Chapter-5
class: center,middle
.section[
Chapter 5  
Provision and Configure AWS VMs
]

---
name: intro-to-provisioners
Using Terraform Provisioners
-------------------------
<br><br><br><br>
Once you've used Terraform to stand up a virtual machine or container, you may wish to configure your operating system and applications. This is where provisioners come in. Terraform supports several different types of provisioners including: Bash, Powershell, Chef, Puppet, Ansible, and more.

.center[https://www.terraform.io/docs/provisioners/index.html]

???
**Terraform works hand-in-hand with these other configuration management tools to install packages, configure applications and change OS settings inside of a virtual machine or container.**

---
name: file-provisioner
The File Provisioner
-------------------------
The Terraform file provisioner copies files from your workstation onto the remote machine. This is one of the simplest ways to put config files into the correct locations on the target machine. In our code we're using the file provisioner to upload a shell script.

```terraform
connection {
  type = "ssh"
  user = "ubuntu"
  private_key = "${file("~/.ssh/id_rsa")}"
  host = "${aws_instance.vault-server.public_ip}"
}
provisioner "file" {
  source      = "files/"
  destination = "/home/ubuntu/"
}
```

Note the *connection* block of code inside the provisioner block. This is where you configure the method for connecting to the target machine. The file provisioner supports both SSH and WinRM connections.

???
SSH for linux, WinRM for your windows machines.

---
name: remote-exec-provisioner
The Remote Exec Provisioner
-------------------------
The remote exec provisioner allows you to execute scripts or other programs on the target host. If its something you can run unattended (for example, a software installer), then you can run it with remote exec.

```terraform
connection {
  type = "ssh"
  user = "ubuntu"
  private_key = "${file("~/.ssh/id_rsa")}"
  host = "${aws_instance.vault-server.public_ip}"
}
provisioner "remote-exec" {
  inline = [
  "chmod -R +x /home/ubuntu/",
  "sleep 30",
  "MYSQL_HOST=${var.prefix}-mysql-server /home/ubuntu/setup.sh"
  ]
}
```

In this example we're running two commands. The first changes the permissions of the script to make it executable. The second command runs the script with variables that we defined earlier.

???
Local exec and remote exec can be used to trigger Puppet or Ansible runs. We do have a dedicated chef provisioner as well.

---
name: puppet-chef-ansible
Terraform & Config Management Tools
-------------------------
.center[![:scale 80%](images/cpa.jpg)]

Terraform works well with common config management tools like Chef, Puppet or Ansible. Below are some links with more information on each:

Official Chef Terraform provisioner:  
https://www.terraform.io/docs/provisioners/chef.html

Run Puppet with 'local-exec':  
https://www.terraform.io/docs/provisioners/local-exec.html

Terraform and Ansible - Better Together:  
https://github.com/scarolan/ansible-terraform

---
name: provisioner-tips
Terraform Provisioner Tips
-------------------------
<br><br>
Terraform provisioners like remote-exec are great when you need to run a few simple commands or scripts. For more complex configuration management you'll want a tool like Chef or Ansible.

Provisioners only run the first time a Terraform run is executed. In this sense, they are not idempotent. If you need ongoing state management of VMs or servers that are long-lived, we recommend using a config management tool.

On the other hand, if you want immutable infrastructure you should consider using our [Packer](https://packer.io) tool.

---
name: chapter-5-lab
.center[.lab-header[👩🏻‍🔬 Lab Exercise 5: Use a Provisioner]]
<br><br><br>
Let's add a simple command to our **remote-exec** block of code.  You can use the 'cowsay' command to output messages into your Terraform log:

```terraform
inline = [
  "chmod +x /home/${var.admin_username}/*.sh",
  "sleep 30",
  "MYSQL_HOST=${var.prefix}-mysql-server /home/${var.admin_username}/setup.sh",
* "cowsay Mooooooo!"
]
```

Run **`terraform apply`** again and see what happens. Did your virtual machine get rebuilt? Why?

Hint: read up on the [terraform taint](https://www.terraform.io/docs/commands/taint.html) command.

???
Explain that provisioners only run when virtual machines are first created. If you need to reprovision, you simply destroy and rebuild the VM. You can force a rebuild with this `terraform taint` command. Don't forget that comma at the end of the setup.sh line!

---
name: chapter-5-lab-answer
.center[.lab-header[👩🏻‍🔬 Lab Exercise 5: Solution]]
<br><br>
The remote-exec provisioner is a [Creation Time](https://www.terraform.io/docs/provisioners/index.html#creation-time-provisioners) Provisioner. It does not run every time you update scripts or code within the remote-exec block. If you need to completely rebuild a virtual machine, you can use the **`terraform taint`** command to mark it for a rebuild. Go ahead and taint your AWS VM and rebuild it before the next chapter.

```bash
terraform taint aws_instance.vault
terraform apply -auto-approve
```

```bash
(remote-exec): ___________
(remote-exec):< Mooooooo! >
(remote-exec): -----------
(remote-exec):        \   ^__^
(remote-exec):         \  (oo)\_______
(remote-exec):            (__)\       )\/\
(remote-exec):                ||----w |
(remote-exec):                ||     ||
 Creation complete after 4m20s...
```

???
You might walk through this one with your students, showing them how easy it is to run commands on your target machine. The cowsay program was installed on your Linux target by the setup.sh script in the files directory.

---
name: chapter-5-review
📝 Chapter 5 Review
-------------------------
.contents[
In this chapter we:
* Learned about Terraform Provisioners
* Explored the **file** and **remote-exec** provisioners
* Learned the **`terraform fmt`** command
* Used the **`terraform taint`** command
* Rebuilt our web server with a new provisioning step
]

---
name: Chapter-6
class: center,middle
.section[
Chapter 6  
Manage and Change Infrastructure State
]

---
name: terraform-state
Terraform State
-------------------------
Terraform is a _stateful_ application. This means that it keeps track of everything you build inside of a **state file**. You may have noticed the terraform.tfstate and terraform.tfstate.backup files that appeared inside your working directory.

The state file is Terraform's source of record for everything it knows about.

```json
{
  "version": 3,
  "terraform_version": "0.11.13",
  "serial": 6,
  "lineage": "983e6899-96f4-ce60-744e-7123bb1fc315",
  "modules": [
      {
          "path": [
              "root"
          ],
          "outputs": {
              "MySQL_Server_FQDN": {
                  "sensitive": false,
                  "type": "string",
                  "value": "labtest1-mysql-server.mysql.database.AWS.com"
```

---
name: terraform-refresh
Terraform Refresh
-------------------------
Sometimes infrastructure may be changed outside of Terraform's control. Virtual machines could be deleted, firewall rules changed, hardware failures could occur causing your infrastructure to look different than what's in the state file.

The state file represents the *last known* state of the infrastructure. If you'd like to check and see if the state file still matches what you built, you can use the **terraform refresh** command.

Note that this does *not* update your infrastructure, it simply updates the state file.

```bash
terraform refresh
```

---
name: change-existing-infra
Changing Existing Infrastructure
-------------------------
During the earlier sections, you learned to write code in small increments, then test your changes with the **`terraform apply`** command. Whenever you run a plan or apply, Terraform reconciles three different data sources:

1.  What you wrote in your code
2.  The state file
3.  What actually exists

Terraform does its best to add, delete, change, or replace existing resources based on what is in your *.tf files. Here are the four different things that can happen to each resource during a plan/apply:

```tex
+   create
-   destroy
-/+ replace
~   update in-place
```

---
name: terraform-destroy-2
Before You Go...
-------------------------
If you are not proceeding to the Vault workshop, please run a **`terraform destroy`** command to delete your lab environment.

Command:
```powershell
terraform destroy
```

Output:
```tex
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

Destroy complete! Resources: 0 destroyed.
```

---
name: additional-resources
Additional Resources
-------------------------
If you'd like to learn more about Terraform on AWS try the links below:

HashiCorp Learning Portal  
https://learn.hashicorp.com/terraform/

Amazon Terraform Quickstarts  
https://docs.Amazon.com/en-us/AWS/terraform/

Terraform with AWS Cloudshell  
https://docs.Amazon.com/en-us/AWS/terraform/terraform-cloud-shell

Terraform AWSrm Provider Documentation  
https://www.terraform.io/docs/providers/AWSrm/

Link to this Slide Deck  
https://bit.ly/hashiAWS

---
name: Ready-fo-More
Ready for More?
-------------------------
<br><br><br>
You can try the [Introduction to Vault](../vault) Workshop, or proceed to the [Intro to Terraform Enterprise](../tfe) Workshop.

The Intro to Vault workshop uses the infrastructure you just built as its lab environment.

Please run **`terraform destroy`** if you're not doing the Vault workshop. This helps us keep our cloud spending under control. You can always spin up a new instance of the workshop lab later.

[Introduction to Vault](../vault) - Learn the Basics of HashiCorp Vault

[Intro to Terraform Enterprise](../tfe) - Explore Terraform Cloud and Enterprise

---
name: Feedback-Survey
Workshop Feedback Survey
-------------------------
<br><br>
.center[
Your feedback is important to us!

The survey is short, we promise:

http://bit.ly/hashiworkshopfeedback
-------------------------
]
