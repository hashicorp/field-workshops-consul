name: Chapter-1
class: title
# Chapter 1
## Introduction to Consul

---
name: HashiCorp-Consul-Overview
Consul Overview
-------------------------
.center[![:scale 10%](images/consul_logo.png)]

HashiCorp Consul is an API-driven service networking solution. It connects and secures all your runtime services across public or private clouds.

For additional descriptions or instructions that expand on this workshop, please see the docs, API guide, and learning site:
* https://www.consul.io/docs/
* https://www.consul.io/api/
* https://learn.hashicorp.com/consul/

---
name: The-Shift
The shift from static to dynamic
-------------------------
.center[![:scale 50%](images/static_to_dynamic.png)]
.center[Physical servers, to VMs, to containers...]

As our applications have shifted from monoliths to microservices, the networking landscape has changed drastically. Let's briefly explore the history  of this shift, and how Consul can help us with its  challenges.

---
name: Client-Server
class: img-right
Introduction of Client & Server
-------------------------
.center[![:scale 100%](images/client_server_flow.png)]

<br><br>
* Single application per Server
* No app mobility
* Security mapped to IP
* Seldom horizontal scale of an app
* High trust zones and perimeter

---
name: Introduction-of-VMs
class: img-right
Introduction of the VM
-------------------------
.center[![:scale 100%](images/vm_flow.png)]

<br><br>
* Better HW utilization
* Basic networking in Hypervisor
* VM mobility
* Some Horizontal scaling
* Load balancers
* Spanning trees

---
name: Introduction-of-the-Fabric
class: img-right
Introduction of the Fabric
-------------------------
.center[![:scale 100%](images/fabric_flow.png)]

<br><br>
* L2 Fabrics
* Mostly proprietary L2 routing
* More single service instances
* More Load Balancers
* Spine & Leaf

---
name: Introduction-of-the-Microservice
class: img-right
Introduction of the Microservice
-------------------------
.center[![:scale 100%](images/microservices.png)]

<br><br>
* Highly maintainable and testable
* Loosely coupled
* Independently deployable
* Organized around business capabilities
* Owned by a small team

---
name: Introduction-of-the-SDN
class: img-right
Introduction of the SDN
-------------------------
.center[![:scale 100%](images/sdn_flow.png)]

<br><br>
* Network automation
* Self-Service
* Separation of duties - Who operates SDN?
* Lower visibility for network admin

---
name: Introduction-of-the-Multi-Cloud-Hybrid
class: img-right
Introduction of Multi-Cloud - Hybrid
-------------------------
.center[![:scale 100%](images/hybrid_cloud_flow.png)]

<br><br>
* Where is my app instance?

---
name: Introduction-of-the-Multi-Cloud-K8s
class: img-right
Introduction of Multi-Cloud - K8s
-------------------------
.center[![:scale 100%](images/hybrid_k8s_flow.png)]

<br><br>
* K8s src IP
* K8s networking - NAT / Calico / Flannel
* Access to K8S service - K8S Ingress et al

---
name: Introduction-Summary
Summary
-------------------------
.center[![:scale 50%](images/static_to_dynamic_flow.png)]
As you can see our networking model has drastically changed.
Let's learn a little more about how Consul works, and then we can revisit these challenges with Consul.

---
name: Live-Demo
class: center,middle
Live Demo
=========================

???
Let's do a short demo to show you one of the use cases Consul can help you solve.
