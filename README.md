#(Divisive)ThreshClust.jl: Simple API For Simple Divisive Threshold Clustering Applications
=================================================================

Threshclust.jl is a very simple API to allow you to do simple clustering jobs, where you can cluster data based on any distance metric you find as long as you provide a partial order upon it. The basic example given is for objets you would like to cluster that have a numeric attribute, but the sky is the limit as long as you can provide a partial order and a metric for an attribute your type manifests. Note that Threshclust was intended for divisive threshold clustering (the intent is to have each entity define their own cluster and exist in other clusters, so that one or more subroutines can be used to pare down membership to different clusters)
```
Usage
using ThreshClust
type MyType
	number
	othernumber
	notanumber
end

mydistancefunction(a::Real, b::Real) = abs(a-b)

array_of_my_types([MyType(1,2,"foo"),MyType(2,4,"bar"),MyType(6,8,"Baz")])
#This is one of the things you need: an array of objects with a field you want to group them by

my_thresholding_criteria = Simple_Threshold_Criteria(:othernumber,mydistancefunction,4)
#Define a thresholding criteria. Right now, for simple thershold criteria, you give it a distance function and pick a maximum value to create clusters by
# I.E: Place vales of type MyType in the same cluster if are seperated by a distance no greater than 4, with distance as defined by mydistancefunction

(cluster_lookup,myarrayofclusteredobjects) = make_simple_threshold_clusters(array_of_my_types,my_thresholding_criteria)
```

A cluster container (what fills `myarrayofclusteredobjects`) contains the object it clusters, the field value being clustered upon, and the cluster number for the item.

Cluster numbers define clusters that are shared between elements. You can see what objects a specific item is clustered with with the cluster_lookup dictionary. If objects share a cluster number, that all objects in that cluster cluster exclusively with one another
i.e: If we want to cluster the numbers 2,6,10,25,28 with a threshold of 5, the cluster numbers will be:

2 -> 1
6 -> 2
10 ->3 
25 ->4
28 ->4

25 and 28 share a cluster number because they are each exclusive members of the same cluster, while 2 is a member of 6's cluster and 6 is a member of 2's cluster and 10's cluster. The actual clusters each element belong to look like this:

2 -> {2,6}
6 -> {2,6,10}
10 -> {6,10}
25 -> {25,28}
28 -> {25,28} 


THIS IS STILL VERY EXPERIMENTAL! IF IT WORKS FOR YOU I'D BE VERY IMPRESSED
