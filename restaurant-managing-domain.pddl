; This domain can model various restaurant management scenarios 
; Restaurant has tables, groups of customers coming to them, and staff members 

(define (domain restaurant-managing) 
	(:requirements :typing :durative-actions :numeric-fluents)
	(:types 
		group table staffmember - object) 
	(:predicates 
	
		; General table-related states
		(waiting-table ?g - group) 
		(table-available ?t - table)
		(member-available ?m - staffmember)
		(seated ?g - group ?t - table) 
		(ordered ?g - group ?t - table) 
		
		; Serving related states
		(served ?g - group) 
		(not-served ?g - group)
		(food-ready ?t - table)
		
		; table joining related states 
		(separate ?t - table)
		(joined ?t - table) 
	) 
	
	(:functions 
		(people-count ?g - group) 
		(table-capacity ?t - table)
	)
	
	(:durative-action seat-group
		:parameters (?m - staffmember ?g - group ?t - table)
		:duration (= ?duration 30)
		:condition (and (at start (waiting-table ?g))
						(over all (table-available ?t))
						(at start (member-available ?m))
						(at start (<= (people-count ?g) (table-capacity ?t))))
		:effect (and (at start (not (member-available ?m)))
					(at end (member-available ?m))
					(at end (seated ?g ?t)) 
					(at end (member-available ?m))
					(at end (not (table-available ?t)))))
	
	; In this simplified model, 30 seconds are spent on each person to take order
	(:durative-action take-order 
		:parameters (?m - staffmember ?g - group ?t - table)
		:duration (= ?duration (* (people-count ?g) 30))
		:condition (and (at start (member-available ?m))
						(at start (seated ?g ?t))) 
		:effect (and (at start (not (member-available ?m)))
					(at end (member-available ?m))
					(at end (ordered ?g ?t))))
					
	; Assumes that every goods served are ready and served in 100s per person. 
	(:durative-action serve
		:parameters (?m - staffmember ?g - group ?t - table) 
		:duration (= ?duration (* (people-count ?g) 100))
		:condition (and (at start (seated ?g ?t))
						(at start (ordered ?g ?t))
						(at start (not-served ?g)) 
						(at start (member-available ?m)))
		:effect (and (at start (not (not-served ?g)))
					(at end (served ?g))
					(at start (not (member-available ?m)))
					(at end (member-available ?m))))
							
	(:durative-action take-payment 
		:parameters (?m - staffmember ?g - group ?t - table) 
		:duration (= ?duration (* (people-count ?g) 60) )
		:condition (and (at start (seated ?g ?t))
						(at start (served ?g))
						(at start (member-available ?m)))
		:effect (and (at start (not (seated ?g ?t)))
					(at end (table-available ?t))
					(at start (not (member-available ?m)))
					(at end (member-available ?m))))
					
	(:durative-action join-tables 
		:parameters (?m -staffmember ?t1 ?t2 - table ) 
		:duration (= ?duration 100) 
		:condition (and (at start (member-available ?m))
						(over all (table-available ?t1))
						(over all (table-available ?t2))
						(over all (separate ?t1)) 
						(over all (separate ?t2)))
		:effect (and (at start (not (member-available ?m)))
					(at end (member-available ?m))
					(at start (not (separate ?t1)))
					(at start (not (separate ?t2)))
					(at start (joined ?t1))
					(at start (joined ?t2))
					(at start (not (table-available ?t2)))
					(at end (increase (table-capacity ?t1) (table-capacity ?t2)))))
						
)
	
	