#ThreshClust.jl: Simple API For Simple Divisive Threshold Clustering Applications
=================================================================

Threshclust.jl is a very simple API to allow you to do simple clustering jobs, where you can cluster data based on any distance metric you find as long as you provide a partial order upon it. The basic example given is for objets you would like to cluster that have a numeric attribute, but the sky is the limit as long as you can provide a partial order and a metric for an attribute your type manifests. Note that Threshclust was intended for divisive threshold clustering 

#Divisive Clustering
ThreshCluster's original use was in solving problems regarding record linkage. Say you have 150,000 objects. Many of those objects are duplicates to within some threshold (i.e: they all have the same weight within some threshold, the same height within some threshold and the same mass within some threshold). While this could be a regression problem, this algorithm is useful when:
1. There are no complicated features and clustering is to be done once for each feature (in the example space above, there are three distinct features to classify on and each is a member of the real numbers, so each has a well-defined partial order and distance function)
2. Each element is different enough in these features that two objects that have similar masses are not likely to also have both similar heights and weights. If this were the case, and there were not other dimensions to exploit, it may be more advisable to consider a learning algorithm working through a regression
3. You are presented with a large number of elements to perform this analysis on 

This library has served well for the applications that conform to the cases above, and benefits most from the design goal of being very simple to operate. 

#Usage
First, define the criteria for clustering. These are defined as objects of type Simple_Threshold_Criteria (in the future, perhaps there will be more complex clustering criteria, but now there is a simple threshold criteria). 
```julia
using ThreshCluster
my_weight_criteria = Simple_Threshold_Criteria(compared_quantity,
					       compared_quantity_accessor,
					       distance_function,
					       threshold)
```
The compared quantity is a symbol for you to use to determine the quantity you are comparing. It is useful for bookkeeping but it could be left to none. The compared_quantity_accessor is the function that must be called on an object in order to obtain the quantity you are clustering on. For instance, if you want to cluster an array of sticks by length, then you would use:
```julia
compared_quantity_accessor = stick->stick.length
```

you could also use `compared_quantity_accessor = stick->getfield(stick,:length)`, but in this case the anonymous function increaes readability

The `distance_function` is the metric you use on two compared quantities. For real numbers you probably want:
`distance_function(x,y) = abs(x-y)`

The threshold is your starting threshold for the inclusion of two objects. Say that you want to cluster all sticks that are within 3 units of length from one another. Then your threshold will be three. Note that as of the current implementation of ThreshClust, there is a sneaky bit of pseudo-learning going on, so you may get sticks within more than three units of length from one another.

Now, all that remains is to pass an array of objects you want to compare, along with your threshold criteria, and ThreshCluster will go to work:

```julia
threshcluster(array_of_objects,my_weight_criteria)
```

#Adaptive Threshold Clustering
As of right now, ThreshCluster only uses an adaptive threshold cluster. This should be changed soon to allow for strict clustering by creating a new type for non-strict criteria, but right now it's current use case calls for it. 

The adaptive threshold clustering means that the clusters are not defined by the absolute threshold criteria, but instead within a triangle around the most geometrically distant member of their cluster. 

I.e: a cluster's radius expands as it adds new members equal to the distance of its radius and the element of the cluster farthest from its center (the seeding value). As such, a cluster includes any elements that can be related by a triangle inequality with any of the other elements in the cluster. This is to make the clustering algorithm more deterministic without regard to the order of the initial array. (If not, the fact that a certain element of the array was chosen to seed the cluster could cause certain elements that could have been included in a cluster to instead form their own cluster that should overlap with the first cluster. The tradeoff of this adaptive clustering is that it is difficult to cluster over a continuous spectrum with broad representation within your array. That is to say, if you are clustering based on lengths, and your objects span a continuum of length from your smallest object to your largest object, this algorithm may fail, as the radius for inclusion would continue to grow). When this is the case, a more granular algorithm such as k-means should probably be employed, as it will guaruntee some degree of separation between your clusters

# EXAMPLE!!!
```julia
Usage
using ThreshClust
type MyType
	number
	othernumber
	notanumber
end

my_compared_quantity = :othernumber

my_distance_function(a::Real, b::Real) = abs(a-b)

my_compared_quantity_accessor(mytype::MyType) = mytype.othernumber

my_threshold = 2

array_of_my_types([MyType(1,2,"foo"),MyType(2,4,"bar"),MyType(6,8,"Baz")])


my_thresholding_criteria = Simple_Threshold_Criteria(my_compared_quantity,
                                                     my_distance_function,
						     my_compared_quantity_accessor,
						     my_threshold)

array_of_clustered_arrays = make_simple_threshold_clusters(array_of_my_types,
                                                           my_thresholding_criteria)
```

