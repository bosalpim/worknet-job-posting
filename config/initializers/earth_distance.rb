ActiveRecord::Base.send :include, EarthDistance::ActsAsGeolocated
ActiveRecord::Relation.send :include, EarthDistance::QueryMethods