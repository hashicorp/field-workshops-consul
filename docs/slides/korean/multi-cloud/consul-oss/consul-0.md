name: Consul-OSS-Workshop
class: Korea, APAC
count: false
![:scale 30%](images/consul_logo.svg)
.titletext[Consul OSS Workshop]
모듯 곳의 모든 서비스를 안전하고 빠르게 연결

???
Consul OSS 초보자 가이드에 오신 것을 환영합니다. 이 슬라이드덱과 함께 제공되는 실습은 강사 주도식 또는 자가지도식 워크샵으로 제공 될 수 있습니다. 이 콘텐츠는 3-4 시간이 소요됩니다.

---
name: Link-to-Slide-Deck
The Slide Deck
-------------------------
<br><br><br>
.center[
링크를 클릭하여 각 환경에서 슬라이드를 확인할 수 있습니다.:

### https://git.io/JnLml
]

???
이 슬라이드는 RemarkJS 프레임 워크 및 Github 페이지를 사용하여 게시됩니다. 슬라이드 데크 및 Instruqt 랩의 소스 코드는 https://www.github.com/hashicorp/field-workshops-consul에서 확인하세요. 이 개인 코드 저장소에 액세스하려면 초대를 받아야 할 수 있습니다.

---
name: Introductions
참여자 소개 시간
-------------------------

.contents[
* 이름 : 
* 직책 : 
* 경험 공유 :
]

???
이 슬라이드를 사용하여 자신을 소개하고 배경 이야기를 약간 제공 한 다음 방을 돌아 다니며 모든 참가자가 자신을 소개하도록합니다.

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
오늘 세션에서는 다음 주제를 다룰 것입니다.
Consul이 왜 필요한지에 대한 개요를 할 것입니다. 그런 다음 아키텍처 관점에서 영사가 어떻게 작동하는지 살펴 보겠습니다. 그런 다음 consul을 사용하는 몇 가지 사용 사례를 살펴 보겠습니다. 그 후 우리는 consul과 편안하게 상호 작용하기 시작하여 서비스 검색으로 이동하고 마지막으로 consul 연결 및 서비스 세분화를 살펴 보는 것으로 시작하여 일부 실습을 진행합니다.