name: Consul-OSS-Workshop
class: Korea, APAC
count: false
![:scale 30%](images/consul_logo.svg)
.titletext[
Consul OSS Workshop]
모든 플랫폼상의 서비스를 안전하게 연결

???
Consul OSS 초보자 가이드에 오신 것을 환영합니다. 이 슬라이드덱과 함께 제공되는 실습은 강사 주도식 또는 자가지도식 워크샵으로 제공 될 수 있습니다. 이 콘텐츠는 3-4 시간이 소요됩니다.

---
name: Link-to-Slide-Deck
The Slide Deck
-------------------------
<br><br><br>
.center[
Follow along on your own computer at this link:

### [https://hashicorp.github.io/field-workshops-consul/slides/multi-cloud/consul-oss](https://hashicorp.github.io/field-workshops-consul/slides/multi-cloud/consul-oss)
]

???
These slides are published using the RemarkJS framework and Github Pages. View the source code for both the slide deck and the Instruqt labs here: https://www.github.com/hashicorp/field-workshops-consul. You may need to be invited to get access to this private code repo.

---
name: Introductions
강사 소개
-------------------------

.contents[
* GS, 이규석
* Sr. Solutions Engineer
* gs@hashicorp.com
]

???
Use this slide to introduce yourself, give a little bit of your background story, then go around the room and have all your participants introduce themselves.

---
name: Table-of-Contents
목차
=========================

1. Consul Overview
1. Consul Use Cases
1. Consul Architecture
1. Consul Basics
    * Lab - Meet Consul
1. Service Discovery
    * Lab - Service Discovery with Consul
1. Service Segmentation
    * Lab - Service Mesh with Consul
    * Bonus Lab - Service Mesh with Consul on K8s
    * Bonus Lab - Service Mesh with Consul Mesh Gateways

Lab : https://play.instruqt.com/hashicorp/topics/consul-workshops

???
For today's session we are going to be covering the following topics.  
We are going to do an overview of why you even need consul.  Then we will go over how consul works from an architecture perspective.  We will then dive into some of the use cases that you would use consul for.  After that we will get our hands dirty with some labs starting with getting comfortable interacting with consul, then moving to service discovery and finally looking at consul connect and service segmentation.  Any questions?  Ok lets go!!
