---
title: "Paper Review: Disaggregated DB"
date: 2020-03-23T18:28:03-07:00
draft: false 
---

Disaggregation is a hot topic.
This week's two paper mainly discussed the recent trend in cloud native database systems.
I believe the first paper (Database High Availability Using SHADOW Systems) is one of the early attempts towards the goal: decouple the computing nodes with the storage nodes.
The second paper is a more complete and more involved, it show cased how cloud native architecture inside the AWS.

### Database High Availability Using SHADOW Systems
Database systems achieves high availability by duplicating the database instances.
One of the duplication is called hot instance, and the other is standby.
This architecture is the most straightforward way to guarantee the system can survive a single not failure,
but it is not the most efficient way, especially in the cloud settings.

In the cloud settings, persistent storage nodes are connected with compute nodes via high speed network, 
while the local storage within the compute nodes are ephemeral.
Persistent storage nodes duplicate their data to avoid single node failure -- this is exactly what DBMS does to achieve high availability.

SHADOW system leverages the fact that in the cloud environment, the persistent storage node is already duplicated and thus is reliable,
a DBMS no longer need to maintain a standby storage instance.
The key idea is to de-couple the transaction processing engine with the storage -- the latter is reliable thanks to the storage-as-a-service :)

### Amazon Aurora: Design Considerations for High Throughput Cloud-Native Relational Databases
This paper is interesting because it provides a view of how industry use the database system, the challenges and the most wanted features.
The more I read these kind of paper, the more I feel the eager for being robust and high-available.
It sometimes makes me frustrated on how the industry can build much more robust and realistic applications than the academia. 

Both paper mentioned the blind replication used on traditional DBMS is undesirable, and the solutions are similar: decouple the computing nodes and the storage nodes.
Combined with a lot of other optimizations, the Aurora can achieve much better performance than any other research prototypes, and it has been deployed for years in the production environments.

Resource disaggregation is extremely suitable for cloud computing, as it allows individual components to scale without impact the rest of the systems.
What are the problems it tries to solve?
An easy answer is scalability, and sometimes availability.
(The availability is a magic word, where the industry cares the most while the academia largely ignore it.)







