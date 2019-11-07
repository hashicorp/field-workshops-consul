name: Chapter-7
class: title
# Appendix

---
name: Section-Break-Gossip-Consensus
class: title

## Gossip & Consensus

---

name: Introduction-to-Consensus
class: compact
Introduction to Consensus
-------------------------

Consul uses a consensus protocol to provide consistency.
It is not necessary to understand consensus in detail, but you below are a few terms you will find useful when learning about Consul.

* **Log** - The primary unit of work in a Raft system is a log entry.
* **FSM (Finite State Machine)** - An FSM is a collection of finite states with transitions between them.
* **Peer set** - The peer set is the set of all members participating in log replication.
* **Quorum** - A quorum is a majority of members from a peer set.
* **Committed Entry** - An entry is considered committed when it is durably stored on a quorum of nodes.
* **Leader** - At any given time, the peer set elects a single node to be the leader.

There is a helpful visualization on the next slide.

---
name: Consensus-Visualization
Consensus - A Visualization
-------------------------
<br><br><br><br>
### .center[
<a href="http://thesecretlivesofdata.com/raft/" target="_blank">Raft Consensus Visualization</a>
]

---
name: Consensus-Modes
class: compact
Consensus - Consistency Modes
-------------------------

While it's not required you understand Consensus under the hood, you should understand the various  consistency  modes so you can optimize for your workload.

* **Default** - Raft makes use of leader leasing, providing a time window in which the leader assumes its role is stable. However, if the old leader services any reads, the values are potentially stale. We make this trade-off because reads are fast, usually strongly consistent, and only stale in a hard-to-trigger situation.

* **Consistent** - This mode is strongly consistent without caveats. It requires that a leader verify with a quorum of peers that it is still leader.  The trade-off is always consistent reads but increased latency due to the extra round trip.

* **Stale** - This mode allows any server to service the read regardless of whether it is the leader. This means reads can be arbitrarily stale but are generally within 50 milliseconds of the leader.  This mode allows reads without a leader meaning a cluster that is unavailable will still be able to respond.

---
name: Consensus-Deployment-Table
class: compact
Consensus - Deployment Table
-------------------------

<br>
<center>
<table class="tg" width=60%>
  <tr>
    <th class="tg-feht">Servers</th>
    <th class="tg-feht">Quorum Size</th>
    <th class="tg-feht">Failure Tolerance</th>
  </tr>
  <tr>
    <td class="tg-3z1b">1</td>
    <td class="tg-3z1b">1</td>
    <td class="tg-3z1b">0</td>
  </tr>
  <tr>
    <td class="tg-2i6h">3</td>
    <td class="tg-2i6h">2</td>
    <td class="tg-2i6h">1</td>
  </tr>
  <tr>
    <td class="tg-3z1b">5</td>
    <td class="tg-3z1b">3</td>
    <td class="tg-3z1b">2</td>
  </tr>
</table>
</center>

This table illustrates the quorum size and failure tolerance for various cluster sizes. The recommended deployment is either 3 or 5 servers. A single server deployment is highly discouraged except for development, as data loss is inevitable in a failure scenario. Wherever possible servers should be located in separate low-latency failure zones.

???
Then, shalt thou count to three. No more. No less. Three shalt be the number thou shalt count, and the number of the counting shall be three. Four shalt thou not count, nor either count thou two, excepting that thou then proceed to three. Five is right out.

---
name: Introduction-to-Gossip
Introduction to Gossip
-------------------------
Consul uses a gossip protocol to manage membership and broadcast messages to the cluster. All of this is provided through the use of the Serf library. The gossip protocol used by Serf is based on "SWIM: Scalable Weakly-consistent Infection-style Process Group Membership Protocol", with a few minor adaptations.

You can read more about Serf <a href="https://www.serf.io/docs/internals/gossip.html" target="_blank">here</a>.

Consul gossip operates two primary pools:
* LAN
* WAN

---
name: Introduction-to-Gossip-LAN-Pool
Introduction to Gossip - LAN Pool
-------------------------

* LAN pool is the smallest atomic unit of a datacenter
* Membership in a LAN pool facilitates the following :
  * Automatic server discovery
  * Distributed failure detection
  * Reliable and fast event broadcasts

???
Each datacenter Consul operates in has a LAN gossip pool containing all members of the datacenter, both clients and servers. The LAN pool is used for a few purposes. Membership information allows clients to automatically discover servers, reducing the amount of configuration needed. The distributed failure detection allows the work of failure detection to be shared by the entire cluster instead of concentrated on a few servers. Lastly, the gossip pool allows for reliable and fast event broadcasts.

---
name: Introduction-to-Gossip-WAN-Pool
Introduction to Gossip - WAN Pool
-------------------------
* A WAN pool is a combination of several consul datacenters join via a WAN link
* Only the consul server nodes participate in the WAN pool
* Information is shared between the consul servers allowing for cross datacenter requests
* Just like in the LAN pool the WAN pool allows for graceful loss of an entire datacenter

???
The WAN pool is globally unique, as all servers should participate in the WAN pool regardless of datacenter. Membership information provided by the WAN pool allows servers to perform cross datacenter requests. The integrated failure detection allows Consul to gracefully handle an entire datacenter losing connectivity, or just a single server in a remote datacenter.

---
name: Introduction-to-Gossip-Visualization-50-Node
class: compact
Introduction to Gossip - Visualization
-------------------------
.center[![:scale 30%](images/gossip_50_node.png)]
.center[50 nodes, ~3.56 gossip cycles] <br>

Gossip in Consul scales logarithmically, so it takes O(logN) rounds in order to reach all nodes.
For a 50 node cluster, we can estimate roughly 3.56 cycles to reach all the nodes.


---
name: Introduction-to-Gossip-Visualization-100-Node
class: compact
Introduction to Gossip - Visualization
-------------------------
.center[![:scale 30%](images/gossip_100_node.png)]
.center[100 nodes, ~4.19 gossip cycles] <br>

For a 100 node clusters, this means roughly 4.19 cycles to reach all nodes. Pretty cool!
Let's look at this for  a large cluster.

---
name: Introduction-to-Gossip-Convergence
Introduction to Gossip - Convergence
-------------------------
.center[![:scale 80%](images/convergence_10k.png)]
.center[10k nodes, ~2 second convergence] <br>

The graph above shows the expected time to reach various states of convergence based on a 10k node cluster. We can converge on almost 100% of the nodes in just two seconds!

???
All the agents that are in a datacenter participate in a gossip protocol. This means there is a gossip pool that contains all the agents for a given datacenter. This serves a few purposes: first, there is no need to configure clients with the addresses of servers; discovery is done automatically. Second, the work of detecting agent failures is not placed on the servers but is distributed. This makes failure detection much more scalable than naive heartbeating schemes. It also provides failure detection for the nodes; if the agent is not reachable, then the node may have experienced a failure.
