name: Chapter-1
class: title
# Chapter 1
## Introduction to Consul

---
name: HashiCorp-Consul-Overview
Consul Overview
-------------------------
.center[![:scale 10%](images/consul_logo.png)]

HashiCorp Consul은 API 기반 서비스 네트워킹 솔루션으로서 퍼블릭과 프라이빗 환경의 모든 런타임 서비스를 연결하고 보호합니다.

이 워크샵의 기반이 되는 추가 설명과 지침이 있는 문서들을 아래에서 확인할 수 있습니다.:
* https://www.consul.io/docs/
* https://www.consul.io/api/
* https://learn.hashicorp.com/consul/

???
Consul is a service-based networking tool, which allows you to manage your applications and services in a much more dynamic and fluid way. It has a full API and enables you to automate deployments and secure services across any cloud--public or private.

Hopefully you're following along with this slide deck on your computer so you can follow the links you see on this page. Of course, you can do so at any time.

---
name: The-Shift
정적인 환경에서 동적인 환경으로의 이동
-------------------------
.center[![:scale 50%](images/static_to_dynamic.png)]
.center[물리적 서버가 가상화, 컨테이너로...]

애플리케이션이 모놀리식에서 마이크로 서비스 아키텍쳐로 변화함에 따라 네트워킹 환경도 크게 변화했습니다. 이런 변화의 역사와 Consul이 이런 상황에서의 문제를 어떻게 해결하고 도울 수 있는지 간략하게 살펴보겠습니다.

???
Our traditional approach to networking has always had its challenges. But even more so today with the dynamic nature of cloud computing and software delivery. And with the move from monolithic applications to microservices, even more demand is put on the networking infrastructure.

So let's do a quick run through our networking history to see how Consul can address these challenges.

---
name: Client-Server
class: img-right
과거 Baremetal 환경에서는...
-------------------------
.center[![:scale 100%](images/client_server_flow.png)]

<br><br>
* 서버 당 단일 애플리케이션
* 앱 이동성 없음
* IP에 매핑 된 보안
* 앱의 수평 적 스케일이 거의 없음
* 높은 신뢰 영역 및 경계

???
The Client-Server model was a pretty big shift back in the day, and many didn't think it would survive. The traditional mainframes didn't require near the network demand that the Client/Server model did, and as you can imagine, it was very expensive to upgrade network equipment to support Client/Server. But the pros outweighed the cons, so companies made the investments.

It wasn't long before we started running into new challenges. With the advent of the world wide web and the dot com boom which followed soon after, we found our computing capabilities were severely lacking.

Each application had its own server (typically over-powered to handle peak times), and that application was often setup by hand, meaning it would be very difficult to move the application to another server. IP addresses were hard-coded in order to secure the server and application. Horizontal scaling was expensive and very manual. Inside the private network, it was a free for all with high-trust zones and all applications could typically talk to one another unhindered.

---
name: Introduction-of-VMs
class: img-right
VM 환경에서의 특징
-------------------------
.center[![:scale 100%](images/vm_flow.png)]

<br><br>
* 더 나은 HW 활용
* 하이퍼 바이저의 기본 네트워킹
* VM 이동성
* 일부 수평 확장
* Load Balancer 환용
* 스패닝 트리 (하나로 부터 분산되는 형태)

???
Fortunately, a relic from the distant past was found, dusted off, restored, vastly improved, and delivered as a new, shiny toy: the Virtual Machine. This gave us better resource utilization of our servers. VMs images could be moved from host to host, which meant horizontal scaling was a little easier to achieve. Virtual computing environments also gave way to broader adoption of load balancing tools, which is still an integral part of servicing applications today.

---
name: Introduction-of-the-Fabric
class: img-right
Fabric한 구조의 환경 특징
-------------------------
.center[![:scale 100%](images/fabric_flow.png)]

<br><br>
* L2 Fabrics
* 대부분 독점적 인 L2 라우팅
* 더 많은 단일 서비스 인스턴스
* 더 많은 Load Balancer
* Spine & Leaf

???
As hypervisors started becoming the standard for data centers, we started seeing that support for VM migrations and mobility across subnets was limited. So L2 fabrics were created in order to stretch L2 VLANs across those subnets, and it provided us with a (mostly) full-mesh network. That meant better connectivity for more services and more load balancers. But these were very complex to implement, and if not done well, would yield poor network performance and outages tended to have a larger blast radius.

---
name: Introduction-of-the-Microservice
class: img-right
마이크로서비스 아케택처 환경
-------------------------
.center[![:scale 100%](images/microservices.png)]

<br><br>
* 높은 유지관리와 테스트는 기본
* 느슨한 결합
* 독립적으로 배포 가능
* 비즈니스 역량을 중심으로 구성
* 소규모 팀이 운영하고 소유함

???
At the same time networking capacity was growing, development teams' frustration was growing with their monolithic application model. Teams were completely dependent on one another, so the slowest team was as fast as your software could be delivered. So they started breaking up portions of their application into smaller, single-purpose services. It was still used by the main application, but it was now decoupled and could be released independent of any other application or service. This meant smaller teams and higher efficiencies.

---
name: Introduction-of-the-SDN
class: img-right
SDN
-------------------------
.center[![:scale 100%](images/sdn_flow.png)]

<br><br>
* Network automation
* Self-Service
* 업무분담 - 누가 SDN을 운영해야 하죠?
* 네트워크 관리자에게 부담이 되는 낮은 가시성

???
다음은 네트워크 자동화 및 셀프 서비스를 가능하게하는 소프트웨어 정의 네트워킹입니다. 이것이 다음 단계 인 것 같죠? 작은 파이썬을 사용하여 네트워크를 스크립팅 할 수 있습니다. 쉽게 들리 죠? 글쎄, 당신이 개발자라면 아마도. 그러나 일반적으로 개발자는 네트워크를 설정하는 방법을 모릅니다. 이로 인해 누가 이런 종류의 네트워크를 유지할 것인지를 보여주는 물음표가있는 표지판이있는 네트워크 관리의 교차로에 놓였습니다.

---
name: Introduction-of-the-Multi-Cloud-Hybrid
class: img-right
멀티/하이브리드 클라우드 환경
-------------------------
.center[![:scale 100%](images/hybrid_cloud_flow.png)]

<br><br>
* 내 애플리케이션 서비스는 대체 어디에?

???
Cloud computing brought us new solutions to old problems, like auto-scaling, managed services, and network security. But connecting our private cloud to a public clouds introduced new challenges. For instance, how does your cloud app connect to your on-premise database? Or how do two different networks communicate when they are both using the same RFC 1918 ip address space?

---
name: Introduction-of-the-Multi-Cloud-K8s
class: img-right
쿠버네티스 같은 컨테이너 환경은?
-------------------------
.center[![:scale 100%](images/hybrid_k8s_flow.png)]

<br><br>
* K8s src IP
* K8s networking - NAT / Calico / Flannel
* Access to K8S service - K8S Ingress et al

???
Kubernetes brought us yet another layer of network abstraction. It has its own network interface for internal networking, and yet it still needs to be able with communicate to the outside world. How does an external service communicate with a service running inside a Kubernetes cluster?

---
name: Introduction-Summary
Summary
-------------------------
.center[![:scale 50%](images/static_to_dynamic_flow.png)]
보시다시피 네트워킹 모델이 크게 변경되었습니다.
Consul의 작동 방식에 대해 조금 더 배우고 Consul과 함께 이러한 문제를 다시 살펴볼 수 있습니다.

???
In summary, networking has changed significantly, but the need to simplify network communication has become more important. So we're going to take some time today to learn how Consul can address these challenges.
