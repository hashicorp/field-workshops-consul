# Intro to Consul - Instructor Guide

### Overview
This guide will prepare you to deliver a half-day [Introduction to Consul workshop](https://hashicorp.github.io/field-workshops-consul/oss). This workshop content is suitable for HashiCorp community members, prospects and customers. The workshop is a combination of lecture slides and hands-on labs that introduce new users to Consul features. This workshop focuses on open-source features and is targeted toward new users. The workshop may be presented in-person, over the web, or as a self-guided tutorial.

The workshop alternates between lectures with accompanying slides and hands-on lab exercises. New concepts that are introduced in the slides are reinforced in the labs. Participants will learn both the theory and practice of Consul. As an instructor you should be well familiar with the slide deck and training labs. Go through the course and make sure you understand all of the major concepts and lab exercises. 

When possible you should attend a live training session to observe and learn from another instructor. We will also have video recordings of this workshop available soon.

### What you will learn
This workshop is a crash course in the Consul OSS adoption journey. Participants will learn the following:

* Consul Overview - History & Adoption
* Consul Architecture - Protocols, Scalability, Consistency, Availability, and Multi-datacenter
* Consul Use Cases - Service Registry & Health Monitoring, Network Middleware Automation, and Zero-Trust Networking
* Consul Basics - Basic Cluster Administration
* Consul Service Discovery - Service Registry
* Consul Service Mesh - Service Segmentation & Advanced Routing


### Prerequisites
Prerequisites are minimal. All that is required to participate in the workshop is a web browser and Internet access. No software needs to be downloaded or installed. Self-contained lab environments run on the Instruqt platform, and markdown-based slide decks are published as Github Pages websites. 

### Email invitation
Here is some boilerplate text you can use or customize when inviting or announcing your workshop:

```
Introduction to HashiCorp Consul
A hands-on technical workshop

Learn how HashiCorp Consul can connect your hybrid infrastructure, whether bare metal, VMs, cloud or containers. Consul is the world's most popular open source service discovery and service mesh tool. In this half day technical workshop you'll learn how to effortlessly manage services and applications in the Consul catalog. Hands-on labs will teach you to easily and securely connect any services on your network.

Topics covered in the workshop include:

* A short history of networking
* Introduction to Consul
* Consul Architecture
* Consul Use Cases
* Service Discovery
* Service Segmentation

The only prerequisites for this workshop are a web browser and willingness to learn.
```

### Markdown Slide Deck
The slide deck for this training is published here:

#### https://hashicorp.github.io/field-workshops-consul/oss

#### Navigation
Use the arrow keys (up/down or left/right) to navigate back and forth between slides.

Press the `P` key to enter presenter mode and reveal the speaker notes.

Press the `C` key to pop open an external window that will stay synced with your speaker notes window. This is useful for keeping notes on your laptop while showing the presentation on the projector.

#### RemarkJS
The slide deck for this training is written completely in [Markdown](https://guides.github.com/features/mastering-markdown/) using the [RemarkJS](https://remarkjs.com/#1) framework. This allows us to publish slide decks from a source code repository. The slide deck is easy to maintain, lightweight, and can be accessed from anywhere. Updates and changes to the deck can be made quickly and efficiently by simply editing the markdown source files. If you find any mistakes or issues with the slides please add them to our issue tracker:

https://github.com/hashicorp/field-workshops-consul/projects/1

### Hands-on Labs
At certain points in the slide deck there are links to the lab exercises. [Instruqt](https://instruqt.com/hashicorp) is our lab platform. Lab exercises can be completed anonymously, but if users want to keep track of their progress they should create accounts on the Instruqt website. There are currently three labs referenced in the slide deck:

https://instruqt.com/hashicorp/tracks/consul-basics
https://instruqt.com/hashicorp/tracks/service-discovery-with-consul
https://instruqt.com/hashicorp/tracks/TBD

Go through each of these tracks from start to finish and make sure you understand them. Students may have questions during the labs. When presenting a workshop be sure to give enough time for all your participants to go through the labs. Remember that this is probably their first time working a tool like Consul.

### The Live Demo
Between Chapters 1 and 2 there is a slide that says *Live Demo*. You can use an instruqt track to do a brief Consul demo for your participants. Follow these steps to do the demo:

#### Setup
1. Right before you start the training, visit https://instruqt.com/hashicorp/tracks/service-discovery-with-consul and work up to the 'Seamless Service Discovery' challenge. Or if need be let your participants take a break after chapter 1 while you set this up. Setup should not take more than 7-8 minutes.
2. Walk through the demo scenario:
> Welcome to Initech. We're trying to expand into the cloud and still manage our legacy infrastructure. We have this gigantic spreadsheet that contains mappings of all our IP addresses and hosts. The spreadsheet is sometimes out of date or not accurate. Hard-coding IPs into config files has been troublesome, slow and error prone.

> What if I could show you a way to automatically fetch the IP address of any service on your network. Imagine a service discovery system that is always up to date, and can even monitor the health of your services, preventing connections to services that are down. Let's take a look at Consul and see how it can help us solve our service discovery problem.

> (Open Consul UI) Here is the Consul UI which shows all the services that consul knows about. I can also see the health status of services along with any tags that are attached to them. You can use tags to separate production environments or create dynamic rules around which services are used. In our demo story the application is having trouble connecting to the database because it's IP address keeps changing.

> If I click through on the mysql service I can see that it is running on the Database node. And here's the IP address, which is always going to be accurate and up to date. With Consul I no longer have to maintain that big excel spreadsheet with IP addresses and ports in it. It's all automatically stored in Consul and kept up to date by our fleet of agents.

> Let's take a peek on the command line and see what we can do with some simple Consul DNS queries:

```
dig -p8600 +short http.service.consul
dig -p8600 +short mysql.service.consul
```

> If you have multiple instances of a thing, Consul will automatically rotate between them. It's like having a free load balancer with built-in health checks:

```
dig -p8600 +short consul.service.consul
```

> (Open website tab) As you can see our website is down. This is because the hard-coded IP address in our config file is wrong. Let's fix that with a Consul DNS address instead. (Open App Config Tab) I'm going to replace this IP address here on line 32 with `mysql.service.consul` which will automatically return the current IP address of a healthy database instance. (Click on the website tab) Now you can see the website has become healthy again, and I'll never have to worry about updating that hard-coded IP address in the future. This is the power of Consul. Now lets talk about some of the most common use cases for consul... (Back to deck for Chapter 2)

### Timing
The following schedule assumes you have a group of participants who are brand new to Consul and service discovery. You should budget between three and four hours for this workshop. This is meant as a guideline, you can adjust as needed.

0:00 - 0:15 - Wait for attendees to arrive, intros, coffee  
0:15 - 0:30 - The history of networking  
0:30 - 1:00 - Consul architecture  
1:00 - 1:30 - Consul use cases  
1:30 - 1:45 - Break  
1:45 - 2:15 - Instruqt Lab Track #1 - Consul Basics  
2:15 - 2:30 - Service discovery lecture  
2:30 - 3:00 - Instruqt Lab Track #2 - Service Discovery  
3:00 - 3:15 - Service mesh lecture  
3:15 - 3:45 - Instruqt Lab Track #3 - Consul Connect  
3:45 - 4:00 - Wrap-up, summary, next steps  

*BONUS TRACKS* - these are intended for intermediate users. You may be able to skip some of the introductory material and dive straight into use cases and labs. If you omit some of the lectures at the beginning these extra labs should fit into a half-day training.

Instruqt Lab Track #4 - Consul Connect Walk - Telemetry, metrics, k8s, grpc, oh my!   
Instruqt Lab Track #5 - Consul Connect Run  - Bringing it  all together - connecting your K8s mesh
