module ThreshClustTypes
"Exports: Simple_Cluster_Container"
abstract Cluster
abstract Cluster_Container
type Simple_Cluster_Container <: Cluster_Container
	#This is a simple cluster container. It is an additive type containing an object, and an array of references to which cluster the object belongs to.
	object
	compared_quantity #This is the quantity of the object that one desires to measure against
	membership
end
export Simple_Cluster_Container
#=type Simple_Cluster <: Cluster=#
	#="""The simple cluster contains a dictionary of cluster profiles (centroids, etc.) indexed to an array of cluster containers. It also contains=#
#=end=#
end 
