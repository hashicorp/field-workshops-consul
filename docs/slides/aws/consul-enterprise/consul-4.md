name: Chapter-5
class: title
# Chapter 5
## Consul Enterprise - Global Visibility, Routing and Scale (GVRS)

---
name: Consul-Enterprise-Global-Visibility-Routing-Scale-Overview
class: img-right
Consul Enterprise - Global Visibility, Routing and Scale (before)
-------------------------
.center[![:scale 100%](images/05-centralize-consul-secrets.png)]

GVRS provides turnkey features for advanced visibility, routing, and scale.

You will use this module to configure advanced routing between Application and Shared Service VPCs

---
name: Consul-Enterprise-Global-Visibility-Routing-Scale-Overview
class: img-right
Consul Enterprise - Global Visibility, Routing and Scale (after)
-------------------------
.center[![:scale 100%](images/10-configure-eks-cluster-segments.png)]

AWS transit gateway will route traffic across VPCs, and to the Shared Service infrastructure.

Traffic is restricted between Application VPCs.

Consul's Network Segments prevent client agent traffic from gossiping across VPCs for performance and cost savings.

---
name: Consul-Enterprise-Global-Visibility-Routing-Scale-Lab
# 👩‍💻 Lab Exercise: Advanced Networking Topologies
In this lab you'll perform the following tasks:
  * Create Transitive Peering using AWS Transit Gateway
  * Provision EKS clusters
  * Configure Consul Network Segments for EKS cluster routes


Your instructor will provide the URL for the lab environment.

🛑 **STOP** after you complete the first quiz.
