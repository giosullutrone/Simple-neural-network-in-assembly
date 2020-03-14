#################################################################################################
# Disclaimer:											#
#################################################################################################
# Made by: Giovanni Sullutrone									#
# Date: 8 march 2020										#
#################################################################################################


#################################################################################################
# .data												#
#################################################################################################
# lr:			Learning rate of the training						#
# weights:		starting weights (MUST BE OF THE SAME SIZE AS THE NUMBER OF INPUTS)	#
# training_x:		training inputs								#
# training_y:		training outputs							#
# text_x:		test_inputs								#
#################################################################################################

		.data
weights:	.float		0.2, 0.4

lr:		.float		0.05

training_x:	.float		0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0
training_y:	.float		0.0, 0.0, 0.0, 1.0

test_x:		.float		1.0, 1.0
test_x_1:	.float		0.0, 1.0

prediction:	.asciiz		"Prediction:"
nl:		.asciiz		"\n"
		.text

#################################################################################################
# functions											#
#################################################################################################
# create_model:					($a0)						#
# train:					($a0, $a1, $a2, $a4)				#
# predict:					($a0)						#
#################################################################################################



main:
		#Create a model with (2) inputs
		addi	$a0, $zero, 2
		jal	create_model
		
		#Predict without training		
		la	$a0, test_x
		jal	predict
		la	$a0, test_x_1
		jal	predict
		
		#Train the model on training_x and training_y with 300 epochs and 4 samples given
		la	$a0, training_x
		la	$a1, training_y
		addi	$a2, $zero, 3000
		addi	$a3, $zero, 4
		jal	train
		
		#Predict with training		
		la	$a0, test_x
		jal	predict
		la	$a0, test_x_1
		jal	predict

		li	$v0, 10
		syscall

#################################################################################################
# create_model											#
#################################################################################################
# Sssign constants, allocate Heap memory needed for the model and generate taylor coefficients	#
#												#
# Parameters:											#
#		$a0: number of inputs								#
# Returns:											#
#												#
#################################################################################################

create_model:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		addi	$a1, $a0, 0
		#Hardwire the output to 1 neuron
		addi	$a0, $zero, 1
		jal	assign_constants
		jal	alloc_heap_memory
		jal	alloc_weights
		jal	alloc_bias
		
		addi	$a0, $s0, 0
		addi	$a1, $s2, 0
		jal	generate_taylor_coeffs
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# predict 											#
#################################################################################################
# Predict the output from the given array of inputs						#
#												#
# Parameters:											#
#		$a0: Address of input array							#
#												#
# Returns:											#
#		$f0: prediction									#
#################################################################################################

predict:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		###########################
		
		#Store (dot product of the set of inputs with the weights) + bias inside out
		#we pass as size, the size of the input
		addi	$t0, $a0, 0
		jal	get_address_of_weights
		addi	$a0, $t0, 0
		addi	$a1, $v0, 0
		addi	$a2, $s5, 0
		jal	dot_1D.s
		#Add the bias to $f0
		jal	get_address_of_bias
		l.s	$f15, 0($v0)
		add.s	$f0, $f0, $f15
		#Store the result placed in $f0 inside the output
		jal	get_address_of_out
		s.s	$f0, 0($v0)
		
		#Calculate sigmoid of the output and store it in place
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a1, $v0, 0
		addi	$a2, $s3, 0
		jal	sigmoid_array.s
		
		#Print "prediction:"
		li	$v0, 4
		la	$a0, prediction
		syscall
		
		#Print the output
		jal	get_address_of_out
		l.s	$f0, 0($v0)
		li	$v0, 2
		add.s	$f12, $f0, $f29
		syscall
		
		#New line
		li	$v0, 4
		la	$a0, nl
		syscall
		
		###########################
   		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# train												#
#################################################################################################
# Train the network on the inputs and outputs given						#
#												#
# Parameters:											#
#		$a0: Address of inputs								#
#		$a1: Address of outputs								#
#		$a2: epochs									#
#		$a3: samples									#
#												#
# Returns:											#
#												#
#################################################################################################
train:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f20
		addi $sp, $sp, -4
		s.s $f20, 0($sp)
		###########################
		
		#Store the number of epochs
		addi	$t0, $a2, 0
		#Store the number of samples
		addi	$t1, $a3, 0
		#Store the number of samples as float
		mtc1	$t1, $f20
		cvt.s.w	$f20, $f20
		#Create counter_epochs
		addi	$t2, $zero, 0
		#Create counter_loop
		addi	$t3, $zero, 0
		#Create counter_array_x
		addi	$t4, $zero, 0
		#Create counter_array_y
		addi	$t5, $zero, 0
		
		#Store address of training_x
		addi	$t6, $a0, 0
		#Store address of training_y
		addi	$t7, $a1, 0

		#Set Epoch_MSE to zero
		add.s	$f16, $f29, $f29
		
epochs_loop:
		#Print the epoch_error and reset it
		li	$v0, 4
		la	$a0, epoch
		syscall
		li	$v0, 1
		addi	$a0, $t2, 0
		syscall
		li	$v0, 4
		la	$a0, nl
		syscall
		li	$v0, 2
		div.s	$f12, $f16, $f20
		syscall
		li	$v0, 4
		la	$a0, nl
		syscall
		
		add.s	$f16, $f29, $f29
		#If did all the required epochs
		beq	$t0, $t2, epochs_loop_end
		#Else:
		#Reset counter_loop
		addi	$t3, $zero, 0
		
steps_loop:
		#If n of samples == counter_loop
		beq	$t1, $t3, steps_loop_end
		#Else:
		#Get current position in the training_x array .data
		#Mul by number of inputs * 4 since we need to move (counter_loop * number_of_inputs) * 4 bytes
		addi	$t4, $t3, 0
		mul	$t4, $t4, $s5
		sll	$t4, $t4, 2
		add	$t4, $t4, $t6
		
		#Get current position in the training_y array .data
		#Mul by 4 since we need to move (4) bytes
		addi	$t5, $t3, 0
		sll	$t5, $t5, 2
		add	$t5, $t5, $t7
		
		#Store (dot product of the set of inputs with the weights) + bias inside out
		#we pass as size, the size of the input
		addi	$a0, $t4, 0
		jal	get_address_of_weights
		addi	$a1, $v0, 0
		addi	$a2, $s5, 0
		jal	dot_1D.s
		#Add the bias to $f0
		jal	get_address_of_bias
		l.s	$f15, 0($v0)
		add.s	$f0, $f0, $f15
		#Store the result placed in $f0 inside the output
		jal	get_address_of_out
		s.s	$f0, 0($v0)
		
		#Calculate sigmoid of the output and store it in place
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a1, $v0, 0
		addi	$a2, $s3, 0
		jal	sigmoid_array.s
		
		#Calculate the MSE error between the training_y and the out
		addi	$a1, $t5, 0
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a2, $s3, 0
		jal	mse_1D.s
		#Store the result placed in $f0 inside the error
		jal	get_address_of_error
		s.s	$f0, 0($v0)
	
		#Add this step's error to the epoch_error
		add.s	$f16, $f16, $f0
		
		#Get (output - training_y)
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a1, $t5, 0
		jal	get_address_of_error
		addi	$a2, $v0, 0
		addi	$a3, $s3, 0
		jal	sub_1D.s
		
		#Get der of output and store it in place
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a1, $v0, 0
		addi	$a2, $s3, 0
		jal	sigmoid_der_array_on_sigmoid_array.s
		
		#Mul the der with the error and store it in the output
		jal	get_address_of_error
		l.s	$f1, 0($v0)
		jal	get_address_of_out
		addi	$a0, $v0, 0
		addi	$a2, $v0, 0
		addi	$a3, $s3, 0
		jal	mul_const_1D.s
		
		#Mul the training_x with the output_delta and place it in the delta_weights
		jal	get_address_of_out
		l.s	$f1, 0($v0)		
		addi	$a0, $t4, 0
		jal	get_address_of_delta_weights
		addi	$a2, $v0, 0
		addi	$a3, $s5, 0
		jal	mul_const_1D.s

		#Mul the delta_weights by the lr and place them in place
		jal	get_address_of_delta_weights
		addi	$a0, $v0, 0
		add.s	$f1, $f27, $f29
		addi	$a2, $v0, 0
		addi	$a3, $s5, 0
		jal	mul_const_1D.s
		
		#Sub element-wise the delta_weights from the weights and store them in weights
		jal	get_address_of_weights
		addi	$a0, $v0, 0
		jal	get_address_of_weights
		addi	$a2, $v0, 0
		jal	get_address_of_delta_weights
		addi	$a1, $v0, 0
		addi	$a3, $s5, 0
		jal	sub_1D.s
		
		#Mul the delta_output with the lr
		jal	get_address_of_out
		l.s	$f15, 0($v0)
		mul.s	$f15, $f15, $f27
		jal	get_address_of_bias
		addi	$a0, $v0, 0
		add.s	$f1, $f15, $f29
		addi	$a2, $v0, 0
		addi	$a3, $zero, 1
		jal	sub_const_1D.s
		
		addi	$t3, $t3, 1
		j	steps_loop
		
steps_loop_end:	
		addi	$t2, $t2, 1
		j	epochs_loop
		
epochs_loop_end:
		#TODO: test a sample
		li	$v0, 4
		la	$a0, epoch_end
		syscall
		#Print weights
		jal	get_address_of_weights
		addi	$a0, $v0, 0
		addi	$a1, $s5, 0
		jal	print_array.s
		
		#Print bias
		jal	get_address_of_bias
		addi	$a0, $v0, 0
		addi	$a1, $zero, 1
		jal	print_array.s
		
		###########################
   		#Restore the previous $f20
		l.s 	$f20, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
    		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#################################################################################################
# precision:		number of factors in taylor's approximation				#
#################################################################################################

		.data
precision:	.word		5
one:		.word		1
neg_one:	.word		-1
neg_one.s:	.float		-1.0
zero.s:		.float		0.0
one.s:		.float		1.0
e.s:		.float		2.71828182846
bias:		.float		1.0
loop:		.asciiz		"loop\n"
epoch:		.asciiz		"Epoch:"
MSE:		.asciiz		"MSE:"
epoch_end:	.asciiz		"Finished!\n"
		.text

#################################################################################################
# Heap Map											#
#################################################################################################
# 4 * precision - bytes for coefficients of taylor series					#
# 4 * size of in - bytes for weights 								#
# 4 * size of in - bytes for delta of weights							#
# 4 * 1 - bytes for bias									#
# 4 * size of out - bytes for output								#
# 1 * 4 - bytes for error									#
#################################################################################################

#################################################################################################
# s registers map										#
#################################################################################################
# $s0 => Heap pointer										#
# $s1 => int one										#
# $s2 => precision const									#
# $s3 => size of out										#
# $s4 => int neg one										#
# $s5 => size of in										#
#################################################################################################

#################################################################################################
# f registers map										#
#################################################################################################
# $f0 => results										#
# $f1 => first paramater									#
# $f2 => second parameter									#
# $f27 => lr											#
# $f28 => -one											#
# $f29 => zero											#
# $f30 => one											#
# $f31 => e											#
# $f14 to $f25 => temp values									#
#################################################################################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#################################################################################################
# assign_constants										#
#################################################################################################
# Store in registers the previously defined constants as specified in s/f registers map		#
#												#
# Parameters:											#
#		$a0: number of inputs								#
#		$a1: number of outputs								#
# Returns:											#
#												#
#################################################################################################

assign_constants:
		#s registers
		lw	$s1, one
		lw	$s2, precision
		addi	$s3, $a0, 0
		lw	$s4, neg_one
		addi	$s5, $a1, 0
		#f registers
		l.s	$f27, lr
		l.s	$f28, neg_one.s
		l.s	$f29, zero.s
		l.s	$f30, one.s
		l.s	$f31, e.s
		
		jr	$ra
		
#################################################################################################
# alloc_heap_memory										#
#################################################################################################
# Allocate in Heap taylor coefficients and array to compute as specified in Heap Map		#
#												#
# Parameters:											#
#												#
# Returns:											#
#												#	
#################################################################################################

alloc_heap_memory:
		#Get precision + size_of_in(weights) + size_of_in(delta of weights) + 1(bias) + size_of_out + 1(error)
		add	$t0, $s2, $s5
		add	$t0, $t0, $s5
		add	$t0, $t0, $s3
		addi	$t0, $t0, 2
		#Allocate $t0 * 4 bytes
		sll	$t0, $t0, 2
		addi	$s0, $gp, 0
		add	$gp, $gp, $t0
		
		jr	$ra
		
#################################################################################################
# get_address_of_weights									#
#################################################################################################
# Get address of the weights array as specified in the Heap Map					#
#												#
# Parameters:											#
#												#
# Returns:											#
# 	$v0: the address of the first array							#
#################################################################################################

get_address_of_weights:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################
		
		#Load the allocated heap starting position in $v0
		addi	$v0, $s0, 0
		#Get offset caused by taylor coeffs
		addi	$t0, $s2, 0
		sll	$t0, $t0, 2
		#Add offset to base address
		add	$v0, $v0, $t0
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		jr	$ra
		
#################################################################################################
# get_address_of_delta_weights									#
#################################################################################################
# Get address of the delta weights array to compute as specified in the Heap Map		#
#												#
# Parameters:											#
#												#
# Returns:											#
# 	$v0: the address of the second array							#
#################################################################################################
		
get_address_of_delta_weights:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################

		#Get address of first array
		jal	get_address_of_weights
		#Calculate offset caused by the weights size
		addi	$t0, $s5, 0
		sll	$t0, $t0, 2
		#Add the offset
		add	$v0, $v0, $t0
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# get_address_of_bias										#
#################################################################################################
# Get address of the bias array to compute as specified in the Heap Map				#
#												#
# Parameters:											#
#												#
# Returns:											#
# 	$v0: the address of the second array							#
#################################################################################################
		
get_address_of_bias:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################

		#Get address of first array
		jal	get_address_of_delta_weights
		#Calculate offset caused by the delta weights size
		addi	$t0, $s5, 0
		sll	$t0, $t0, 2
		#Add the offset
		add	$v0, $v0, $t0
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# get_address_of_out										#
#################################################################################################
# Get address of the out array to compute as specified in the Heap Map				#
#												#
# Parameters:											#
#												#
# Returns:											#
# 	$v0: the address of the second array							#
#################################################################################################
		
get_address_of_out:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################

		#Get address of first array
		jal	get_address_of_bias
		#Calculate offset caused by the bias size
		addi	$t0, $zero, 1
		sll	$t0, $t0, 2
		#Add the offset
		add	$v0, $v0, $t0
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# get_address_of_error										#
#################################################################################################
# Get address of the error array to compute as specified in the Heap Map			#
#												#
# Parameters:											#
#												#
# Returns:											#
# 	$v0: the address of the second array							#
#################################################################################################
		
get_address_of_error:
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################

		#Get address of first array
		jal	get_address_of_out
		#Calculate offset caused by the out size
		addi	$t0, $s3, 0
		sll	$t0, $t0, 2
		#Add the offset
		add	$v0, $v0, $t0
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# alloc_weights											#
#################################################################################################
# Allocate in the Heap the weights from the .data as specified in the Heap Map			#
#												#
# Parameters:											#
#												#
# Returns:											#
#												#
#################################################################################################

alloc_weights:		
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		#Save size_of_array in $t0
		addi	$t0, $s5, 0
		
		#Create counter_loop
		li	$t1, 0
		#Create counter_array_data
		li	$t2, 0
		#Create counter_array_heap
		li	$t3, 0
		#Starting position of array in .data
		la	$t4, weights
		
		#Starting position of array in heap
		jal	get_address_of_weights
		addi	$t5, $v0, 0

alloc_weights_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, alloc_weights_loop_end
		#Else:
		
		#Get current position in the array_data
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Load the value of the array_data into $f15
		l.s	$f15, 0($t2)
		#Store the value of $f15 into current array_heap position
		s.s	$f15, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	alloc_weights_loop
		
alloc_weights_loop_end:
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra

#################################################################################################
# alloc_bias											#
#################################################################################################
# Allocate in the Heap the bias from the .data as specified in the Heap Map			#
#												#
# Parameters:											#
#												#
# Returns:											#
#												#
#################################################################################################

alloc_bias:	
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
			
		#Save size_of_array in $t0
		addi	$t0, $zero, 1
		
		#Create counter_loop
		li	$t1, 0
		#Create counter_array_data
		li	$t2, 0
		#Create counter_array_heap
		li	$t3, 0
		#Starting position of array in .data
		la	$t4, bias
		
		#Starting position of array in heap
		jal	get_address_of_bias
		addi	$t5, $v0, 0

alloc_bias_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, alloc_bias_loop_end
		#Else:
		
		#Get current position in the array_data
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Load the value of the array_data into $f15
		l.s	$f15, 0($t2)
		#Store the value of $f15 into current array_heap position
		s.s	$f15, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	alloc_bias_loop
		
alloc_bias_loop_end:
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra

#################################################################################################
# internal functions										#
#################################################################################################
# factorial:					($a0) => ($v0)					#
# factorial_minus_1:				($a0) => ($f0)					#
# generate_taylor_coeffs:			($a0, $a1)					#
# pow.s:					($f1, $a0) => ($f0)				#
# centered_pow.s:				($f1, $f2, $a0) => ($f0)			#
# taylor_of_exp.s:***				($f1) => ($f0)					#
# sigmoid.s:					($f1) => ($f0)					#
# sigmoid_array.s:				($a0, $a1, $a2)					#
# sigmoid_der_array.s:				($a0, $a1, $a2)					#
# sigmoid_der_array_on_sigmoid_array.s:		($a0, $a1, $a2)					#
# print_array.s:				($a0, $a1)					#
# dot_1D.s					($a0, $a1, $a2) => ($f0)			#
# mse_1D.s					($a0, $a1, $a2) => ($f0)			#
# mul_1D.s					($a0, $a1, $a2, $a3)				#
# div_1D.s					($a0, $a1, $a2, $a3)				#
# add_1D.s					($a0, $a1, $a2, $a3)				#
# sub_1D.s					($a0, $a1, $a2, $a3)				#
# mul_const_1D.s				($a0, $f1, $a2, $a3)				#
# div_const_1D.s				($a0, $f1, $a2, $a3)				#
# add_const_1D.s				($a0, $f1, $a2, $a3)				#
# sub_const_1D.s				($a0, $f1, $a2, $a3)				#
#												#
# ***: uses global value									#
#################################################################################################

#################################################################################################
# generate_taylor_coeffs									#
#################################################################################################
# Takes the address of the array, its size (the precision value) and generate (precision)	#
# number of coeffs and stores them inside the array						#
#												#
# Parameters:											#
#		$a0: address of the array							#
#		$a1: number of coeffs								#
# Returns:											#
#												#	
#################################################################################################

generate_taylor_coeffs:
		#TODO: Should add error checking
		
		#Store the current $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Save precision in $t7
		addi	$t0, $a1, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_array
		li	$t2, 0
		#Store starting position of memory
		addi	$t3, $a0, 0
		
generate_taylor_coeffs_loop:
		#If counter_loop == precision
		beq	$t1, $t0, generate_taylor_coeffs_loop_end
		#Else:
		
		#Get current position in the heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t3

		#Get factorial of counter_loop
		#Set the param
		addi	$a0, $t1, 0
		#Call the function
		jal	factorial_minus_1
		
		#Store the float from $f0 to heap
		#Move $f0 to $t4
		mfc1	$t4, $f0
		#Store $t4 to heap
		sw	$t4, 0($t2)
		
		#Increment counter and recall loop
		addi	$t1, $t1, 1
		j	generate_taylor_coeffs_loop
		
generate_taylor_coeffs_loop_end:
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# factorial											#
#################################################################################################
# Takes an integer and computes n!								#
#												#
# Parameters:											#
#	$a0: an integer										#
#												#
# Returns:											#
#	$v0: n!											#	
#################################################################################################

factorial:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################
				
		#If $a0 is equal to zero => 1
		beq	$a0, $zero, factorial_return_1
		#Else:
		#Load the putput with 1
		li	$v0, 1
		#Create counter_loop
		li	$t0, 1
factorial_loop:
		#If the counter is greater than $a0
		bgt	$t0, $a0, factorial_loop_end
		#Else:
		#Multiply $vo with the counter
		mul	$v0, $v0, $t0
		#Increase the counter_loop
		addi	$t0, $t0, 1
		j	factorial_loop
		
factorial_loop_end:
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		jr	$ra
		
factorial_return_1:
		li	$v0, 1
		
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
		
		jr	$ra
		
#################################################################################################
# factorial_minus_1										#
#################################################################################################
# Takes an integer and computes 1/(n!)								#
#												#
# Parameters:											#
#	$a0: an integer										#
#												#
# Returns:											#
#	$f0: 1/(n!)										#
#################################################################################################

factorial_minus_1:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		###########################
		
		#Get factorial of n
		jal	factorial
		#Store the factorial from $v0
		addi	$t0, $v0, 0
		#Move $t0 to $f15 of the coproc1
		mtc1	$t0, $f15
		#Convert it to float
		cvt.s.w	$f15, $f15
		#In $f0 save (1.0 / $f15)
		div.s	$f0, $f30, $f15
		
		###########################
   		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# pow.s												#
#################################################################################################
# Take a float and an integer and return (float) ^ (int)					#
#												#
# Parameters:											#
#	$f1: a single percision float								#
#	$a0: an integer										#
#												#
# Returns:											#
#	$f0: ($f1)^$a0										#
#################################################################################################

pow.s:		
		#If $a0 == 0
		beq	$a0, $zero, pow.s_return_1
		#Else if $a0 < 0:
		blt	$a0, $zero, pow.s_neg
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		###########################
		
		#Create a counter_loop
		li	$t0, 2
		#Assign $f1 to $f0
		add.s	$f0, $f1, $f29
pow.s_loop:
		#If counter_loop > $a0:
		bgt	$t0, $a0, pow.s_loop_end
		#Else:
		#Mul $f0 by $f0 and store it in $f0
		mul.s	$f0, $f0, $f0
		#Increment counter_loop and recall loop
		addi	$t0, $t0, 1
		j	pow.s_loop
		
pow.s_loop_end:
		###########################
		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra
		
pow.s_return_1:
		add.s	$f0, $f30, $f29	
		jr	$ra

pow.s_neg:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#li	$v0, 1
		#syscall
		
		#Change sign of $a0
		mul	$a0, $a0, $s4
		
		#li	$v0, 1
		#syscall
		
		#Recall pow.s with the new $a0
		jal	pow.s
		
		#Divide 1 by the result of pow.s
		div.s	$f0, $f30, $f0
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# centered_pow.s										#
#################################################################################################
# Take two float (x, x0), one int and calculates (x - x0)^(int)					#
#												#
# Parameters:											#
#	$f1: a single precision float => x							#
#	$f2: a single precision float => center (x0)						#
#	$a0: an integer										#
#												#
# Returns:											#
#	$f0: ($f1 - $f2)^$a0									#
#################################################################################################

centered_pow.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Get ($f1 - $f2) ^ $a0
		#Store $f1 - $f2 in $f1
		sub.s	$f1, $f1, $f2
		#Get the new $f1 ^ $a0
		jal	pow.s
		
		#The result is already in $f0 so:		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# taylor_of_exp.s										#
#################################################################################################
# Takes one float (x) and returns an approximation of e^x					#
#												#
# Parameters:											#
#	$f1: a single precision float => x							#
#												#
# Returns:											#
#	$f0: e^($f1)										#
#												#
#	or											#
#	$f0: taylor series with precision number of factors and centered around x0		#
#	Where x0 = floor of x									#
#################################################################################################

taylor_of_exp.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $t8
		addi $sp, $sp, -4
		sw $t8, 0($sp)
		#Store the previous $t9
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		#Store the previous $f18
		addi $sp, $sp, -4
		s.s $f18, 0($sp)
		#Store the previous $f20
		addi $sp, $sp, -4
		s.s $f20, 0($sp)
		#Store the previous $f21
		addi $sp, $sp, -4
		s.s $f21, 0($sp)
		###########################

		#Store $f1 inside $f15
		add.s	$f15, $f1, $f29
		#Store floor of $f1 inside $f16 (x0)
		floor.w.s	$f16, $f1
		#Store the integer to $t9
		mfc1		$t9, $f16
		
		#addi	$a0, $t9, 0
		#li 	$v0, 1
		#syscall
		
		#Convert it back to float
		cvt.s.w		$f16, $f16
		
		#Objective: 	series of beta=0 to beta=precision - 1 of (alpha_of_beta) * e^(x0) * (x - x0)^(beta)
		
		#Get e^(x0) and store it inside $f17
		add.s	$f1, $f31, $f29
		addi	$a0, $t9, 0
		jal	pow.s
		add.s	$f17, $f0, $f29
		
		#Save precision in %t7
		addi	$t7, $s2, 0
		#Create counter_loop
		li	$t8, 0
		#Create counter_array
		li	$t9, 0
		
		#Set $f0 to 0
		add.s	$f0, $f29, $f29
		
		#Clear $f21
		add.s	$f21, $f29, $f29
		
taylor_of_exp.s_loop:
		#If counter_loop == precision
		beq	$t8, $t7, taylor_of_exp.s_loop_end
		#Else:
		
		#Get current position in the heap
		addi	$t9, $t8, 0
		sll	$t9, $t9, 2
		add	$t9, $t9, $s0

		#Store inside $f18 e^x0
		add.s	$f18, $f17, $f29
		
		#Store the current taylor coeff inside $f20
		l.s	$f20, 0($t9)
		#Mul $f20 by $f18 and store it inside $f18 (alpha * e^(x0))
		mul.s	$f18, $f20, $f18
		
		#Store centered_pow.s inside $f19
		#Set parameters
		add.s	$f1, $f15, $f29
		add.s	$f2, $f16, $f29
		addi	$a0, $t8, 0
		#Get centered_pow.s
		jal	centered_pow.s
		add.s	$f20, $f0, $f29
		
		#Mul $f20 by $f18 and store it inside $f18 (alpha_of_beta * e^(x0) * (x - x0)^(beta))
		mul.s	$f18, $f20, $f18
		
		#Add $f18 to $f0 ($f0 = $f0 + beta order of approx)
		add.s	$f21, $f21, $f18
		
		#Increment counter and recall loop
		addi	$t8, $t8, 1
		j	taylor_of_exp.s_loop
		
taylor_of_exp.s_loop_end:
		#Move $f21 to $f0
		add.s	$f0, $f21, $f29

		###########################
   		#Restore the previous $f21
		l.s 	$f21, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f20
		l.s 	$f20, 0($sp)
   		addi 	$sp, $sp, 4
    		#Restore the previous $f18
		l.s 	$f18, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t9
		lw 	$t9, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t8
		lw 	$t8, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
		###########################

		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra

#################################################################################################
# sigmoid.s											#
#################################################################################################
# Takes one float (x) and returns an approximation of the sigmoid(x)				#
#												#
# Parameters:											#
#	$f1: a single precision float								#
#												#
# Returns:											#
#	$f0: sigmoid($f1)									#
#################################################################################################

sigmoid.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $f15
		addi 	$sp, $sp, -4
		s.s 	$f15, 0($sp)
		###########################
		
		#Change sign of $f1
		mul.s	$f1, $f1, $f28
		
		#Get approximation of exp($f1) (i.e.: e^(-x)) and store it inside $f15
		#The parameters are already in the right place
		jal	taylor_of_exp.s
		add.s	$f15, $f0, $f29
		
		#Add 1.0 to $f15
		add.s	$f15, $f15, $f30
		
		#Divide 1 / ($f15) (i.e.: 1/ (1 + e^(-x)))
		div.s	$f0, $f30, $f15
		
		###########################
   		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		###########################
		
		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# sigmoid_array.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, its size	#
# and assign the sigmoid of the first array (element-wise) to the second array			#
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: size of array									#
#												#
# Returns:											#
#												#
#################################################################################################

sigmoid_array.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
   		###########################
		
		#Save size_of_array in $t1
		addi	$t1, $a2, 0
		#Create counter_loop
		li	$t2, 0
		#Create counter_first_array
		li	$t3, 0
		#Create counter_second_array
		li	$t4, 0
		
		#Save starting position of the first array (source)
		addi	$t5, $a0, 0
		#Save starting position of the second array (destination)
		addi	$t6, $a1, 0
		
sigmoid_array.s_loop:
		#If counter_loop == size_of_array
		beq	$t2, $t1, sigmoid_array.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t3, $t2, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Get current position in the second array_heap
		addi	$t4, $t2, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t6
		
		#Get sigmoid of current element
		#Get value from the array and store it inside $f1
		l.s	$f1, 0($t3)
		jal	sigmoid.s
		#Store the result inside the second array 
		s.s	$f0, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t2, $t2, 1
		j	sigmoid_array.s_loop
		
sigmoid_array.s_loop_end:
		###########################
		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################

		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# sigmoid_der_array.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, its size	#
# and assign the derivative of the sigmoid of the first array (element-wise) 			#
# to the second array										#
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: size of array									#
#												#
# Returns:											#
#												#
#################################################################################################

sigmoid_der_array.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		###########################
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $f22
		addi $sp, $sp, -4
		s.s $f22, 0($sp)
		#Store the previous $f23
		addi $sp, $sp, -4
		s.s $f23, 0($sp)
   		###########################
		
		#Save size_of_array in $t1
		addi	$t1, $a2, 0
		#Create counter_loop
		li	$t2, 0
		#Create counter_first_array
		li	$t3, 0
		#Create counter_second_array
		li	$t4, 0
		
		#Save starting position of the first array (source)
		addi	$t5, $a0, 0
		#Save starting position of the second array (destination)
		addi	$t6, $a1, 0
		
sigmoid_der_array.s_loop:
		#If counter_loop == size_of_array
		beq	$t2, $t1, sigmoid_der_array.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t3, $t2, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Get current position in the second array_heap
		addi	$t4, $t2, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t6
		
		#Get sigmoid of current element
		#Get value from the first array and store it inside $f1
		l.s	$f1, 0($t3)
		jal	sigmoid.s
		#Store the result inside $f22
		add.s	$f22, $f0, $f29
		#Subtract the sigmoid from 1 and store it inside $f23
		sub.s	$f23, $f30, $f22
		#Mul $f22 by $f23 and store it inside $f22
		mul.s	$f22, $f22, $f23
		
		#Store the result inside the second array
		s.s	$f22, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t2, $t2, 1
		j	sigmoid_der_array.s_loop
		
sigmoid_der_array.s_loop_end:
		###########################
  		#Restore the previous $f23
		l.s 	$f23, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f22
		l.s 	$f22, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################

		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# sigmoid_der_array_on_sigmoid_array.s								#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, its size	#
# and assign the derivative of the sigmoid of the first array (element-wise) 			#
# to the second array										#
#												#
# IT ASSUMES THE FIRST ARRAY ALREADY HAS THE SIGMOID STORED					#
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: size of array									#
#												#
# Returns:											#
#												#
#################################################################################################

sigmoid_der_array_on_sigmoid_array.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $f22
		addi $sp, $sp, -4
		s.s $f22, 0($sp)
		#Store the previous $f23
		addi $sp, $sp, -4
		s.s $f23, 0($sp)
   		###########################
		
		#Save size_of_array in $t1
		addi	$t1, $a2, 0
		#Create counter_loop
		li	$t2, 0
		#Create counter_first_array
		li	$t3, 0
		#Create counter_second_array
		li	$t4, 0
		
		#Save starting position of the first array (source)
		addi	$t5, $a0, 0
		#Save starting position of the second array (destination)
		addi	$t6, $a1, 0
		
sigmoid_der_array_on_sigmoid_array.s_loop:
		#If counter_loop == size_of_array
		beq	$t2, $t1, sigmoid_der_array_on_sigmoid_array.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t3, $t2, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Get current position in the second array_heap
		addi	$t4, $t2, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t6
		
		#Get sigmoid of current element
		#Get value from the first array and store it inside $f22
		l.s	$f22, 0($t3)
		#Subtract the sigmoid from 1 and store it inside $f23
		sub.s	$f23, $f30, $f22
		#Mul $f22 by $f23 and store it inside $f22
		mul.s	$f22, $f22, $f23
		
		#Store the result inside the second array
		s.s	$f22, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t2, $t2, 1
		j	sigmoid_der_array_on_sigmoid_array.s_loop
		
sigmoid_der_array_on_sigmoid_array.s_loop_end:
		###########################
  		#Restore the previous $f23
		l.s 	$f23, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f22
		l.s 	$f22, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################

		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra
		
#################################################################################################
# print_array.s											#
#################################################################################################
# Takes the address of the array, its size and prints the stored values				#
#												#
# Parameters:											#
#	$a0: address of the array								#
#	$a1: size of the array									#
#												#
# Returns:											#
#												#
#################################################################################################


print_array.s:		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		###########################

		#Save size_of_array in $t0
		addi	$t0, $a1, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_array
		li	$t2, 0

print_array.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, print_array.s_loop_end
		#Else:
		
		#Get current position in the heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $a0
		
		#Set syscall instruction for float print
		li	$v0, 2
		#Load the value to $f12
		l.s	$f12, 0($t2)
		#Execute print
		syscall
		
		#Store the original $a0 in stack
		addi $sp, $sp, -4
		sw $a0, 0($sp)
		
		#Print new-line
		li	$v0, 4
		la	$a0, nl
		syscall
		
		#Restore original $a0
		lw 	$a0, 0($sp)
   		addi 	$sp, $sp, 4
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	print_array.s_loop
		
print_array.s_loop_end:
		###########################
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################

		jr	$ra

#################################################################################################
# dot_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, their size	#
# and calculates the dot product between the first array and the transposed of the second	#
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: size of array									#
#												#
# Returns:											#
# 	$f0: result of the dot product $a0 * ($a1)^T						#
#################################################################################################

dot_1D.s:		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a2, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		
		#Save starting position of the first array (source)
		addi	$t4, $a0, 0
		#Save starting position of the second array (destination)
		addi	$t5, $a1, 0
		
		#Set $f0 to 0
		add.s	$f0, $f29, $f29
		
dot_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, dot_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Calculate the product between the two current values
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t3)
		#Do the product and save it inside $f17
		mul.s	$f17, $f15, $f16
		
		#Add the previous result to $f0
		add.s	$f0, $f0, $f17
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	dot_1D.s_loop
		
dot_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra

#################################################################################################
# mse_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, their size	#
# and calculates the MSE of the first array and the second array where the first is the 	#
# ground-truth and the second is the prediction							#
#												#
# Parameters:											#
#	$a0: address first array => y_true							#
#	$a1: address of second array => y_pred							#
#	$a2: size of array									#
#												#
# Returns:											#
# 	$f0: result of the MSE between second_array and first_array				#
#	     i.e.: mean of (y_pred - y_true)^2							#
#################################################################################################

mse_1D.s:
		#Store this function's $ra in stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		#Store the previous $f18
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t1, $a2, 0
		#Create counter_loop
		li	$t2, 0
		#Create counter_first_array
		li	$t3, 0
		#Create counter_second_array
		li	$t4, 0
		
		#Save starting position of the first array (source)
		addi	$t5, $a0, 0
		#Save starting position of the second array (destination)
		addi	$t6, $a1, 0
		
		#Set $f17 to 0
		add.s	$f17, $f29, $f29
		
mse_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t2, $t1, mse_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t3, $t2, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Get current position in the second array_heap
		addi	$t4, $t2, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t6
		
		#Calculate (second_array - first_array)^2
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t3)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t4)
		#We can call the centered_pow.s with first_array as center
		#$t0 is in use by pow.s
		add.s	$f1, $f16, $f29
		add.s	$f2, $f15, $f29
		addi	$a0, $zero, 2
		jal	centered_pow.s
		#Sum the result with $f17
		add.s	$f17, $f17, $f0
		
		#Increment counter_loop and recall loop
		addi	$t2, $t2, 1
		j	mse_1D.s_loop
		
mse_1D.s_loop_end:
		#Move $t1 to $f18 and convert it to float
		mtc1		$t1, $f18
		cvt.s.w		$f18, $f18
		#Divide the summation in $f17 by size _of_array
		div.s	$f17, $f17, $f18
		#Store the result in $f0
		add.s	$f0, $f17, $f29

		###########################
  		#Restore the previous $f18
		l.s 	$f18, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t5
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################

		#Load the old $ra and return
		lw 	$ra, 0($sp)
   		addi 	$sp, $sp, 4
		jr	$ra

#################################################################################################
# mul_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the element-wise mul between the first array	#
# and the second and stores it inside the third							#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: address of third array								#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

mul_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		#Create counter_third_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t5, $a0, 0
		#Save starting position of the second array
		addi	$t6, $a1, 0
		#Save starting position of the third array (destination)
		addi	$t7, $a2, 0
		
mul_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, mul_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t5
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t6
		
		#Get current position in the third array_heap
		addi	$t4, $t1, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t7
		
		#Calculate the product between the two current values
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t3)
		#Do the difference and save it inside $f17
		mul.s	$f17, $f15, $f16

		#Store the value inside the third array
		s.s	$f17, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	mul_1D.s_loop
		
mul_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra

#################################################################################################
# div_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the element-wise div between the first array	#
# and the second and stores it inside the third							#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: address of third array								#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

div_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		#Create counter_third_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t5, $a0, 0
		#Save starting position of the second array
		addi	$t6, $a1, 0
		#Save starting position of the third array (destination)
		addi	$t7, $a2, 0
		
div_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, div_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t5
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t6
		
		#Get current position in the third array_heap
		addi	$t4, $t1, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t7
		
		#Calculate the product between the two current values
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t3)
		#Do the difference and save it inside $f17
		div.s	$f17, $f15, $f16

		#Store the value inside the third array
		s.s	$f17, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	div_1D.s_loop
		
div_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra

#################################################################################################
# add_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the sum between the first array 		#
# and the second and stores it inside the third							#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: address of third array								#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

add_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		#Create counter_third_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t5, $a0, 0
		#Save starting position of the second array
		addi	$t6, $a1, 0
		#Save starting position of the third array (destination)
		addi	$t7, $a2, 0
		
add_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, add_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t5
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t6
		
		#Get current position in the third array_heap
		addi	$t4, $t1, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t7
		
		#Calculate the product between the two current values
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t3)
		#Do the difference and save it inside $f17
		add.s	$f17, $f15, $f16

		#Store the value inside the third array
		s.s	$f17, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	add_1D.s_loop
		
add_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra

#################################################################################################
# sub_1D.s											#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the difference between the first array 	#
# and the second and stores it inside the third	(first array - second array)			#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$a1: address of second array								#
#	$a2: address of third array								#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

sub_1D.s:		
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $t6
		addi $sp, $sp, -4
		sw $t6, 0($sp)
		#Store the previous $t7
		addi $sp, $sp, -4
		sw $t7, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		#Create counter_third_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t5, $a0, 0
		#Save starting position of the second array
		addi	$t6, $a1, 0
		#Save starting position of the third array (destination)
		addi	$t7, $a2, 0
		
sub_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, sub_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t5
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t6
		
		#Get current position in the third array_heap
		addi	$t4, $t1, 0
		sll	$t4, $t4, 2
		add	$t4, $t4, $t7
		
		#Calculate the product between the two current values
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Get value from the second array and store it inside $f16
		l.s	$f16, 0($t3)
		#Do the difference and save it inside $f17
		sub.s	$f17, $f15, $f16

		#Store the value inside the third array
		s.s	$f17, 0($t4)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	sub_1D.s_loop
		
sub_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $t7
		lw 	$t7, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t6
		lw 	$t6, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra

#################################################################################################
# mul_const_1D.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the mul between the first array 		#
# and the const element-wise and stores it inside the second array				#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$f1: constant										#
#	$a2: address of destination array							#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

mul_const_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t4, $a0, 0
		#Save starting position of the second array
		addi	$t5, $a2, 0
		
		#Store constant in $f16
		add.s	$f16, $f1, $f29
		
mul_const_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, mul_const_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Calculate the sub between the current array value and the constant
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Do the sub and save it inside $f17
		mul.s	$f17, $f15, $f16

		#Store the value inside the second array
		s.s	$f17, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	mul_const_1D.s_loop
		
mul_const_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra
		
#################################################################################################
# div_const_1D.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the div between the first array 		#
# and the const element-wise and stores it inside the second array				#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$f1: constant										#
#	$a2: address of destination array							#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

div_const_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t4, $a0, 0
		#Save starting position of the second array
		addi	$t5, $a2, 0
		
		#Store constant in $f16
		add.s	$f16, $f1, $f29
		
div_const_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, div_const_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Calculate the div between the current array value and the constant
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Do the sub and save it inside $f17
		div.s	$f17, $f15, $f16

		#Store the value inside the second array
		s.s	$f17, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	div_const_1D.s_loop
		
div_const_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra
														
#################################################################################################
# add_const_1D.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the sum between the first array 		#
# and the const element-wise and stores it inside the second array				#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$f1: constant										#
#	$a2: address of destination array							#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

add_const_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t4, $a0, 0
		#Save starting position of the second array
		addi	$t5, $a2, 0
		
		#Store constant in $t6
		add.s	$f16, $f1, $f29
		
add_const_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, add_const_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Calculate the product between the current array value and the constant
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Do the sum and save it inside $f17
		add.s	$f17, $f15, $f16

		#Store the value inside the second array
		s.s	$f17, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	add_const_1D.s_loop
		
add_const_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra
		
#################################################################################################
# sub_const_1D.s										#
#################################################################################################
# Takes the address of the array, the address of a second array of the same size, 		#
# the destination array, their size and calculates the sub between the first array 		#
# and the const element-wise and stores it inside the second array				#				
#												#
# Parameters:											#
#	$a0: address first array								#
#	$f1: constant										#
#	$a2: address of destination array							#
#	$a3: size of array									#
#												#
# Returns:											#
# 												#
#################################################################################################

sub_const_1D.s:
		###########################
		#Store the previous $t0
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		#Store the previous $t1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		#Store the previous $t2
		addi $sp, $sp, -4
		sw $t2, 0($sp)
		#Store the previous $t3
		addi $sp, $sp, -4
		sw $t3, 0($sp)
		#Store the previous $t4
		addi $sp, $sp, -4
		sw $t4, 0($sp)
		#Store the previous $t5
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		#Store the previous $f15
		addi $sp, $sp, -4
		s.s $f15, 0($sp)
		#Store the previous $f16
		addi $sp, $sp, -4
		s.s $f16, 0($sp)
		#Store the previous $f17
		addi $sp, $sp, -4
		s.s $f17, 0($sp)
		###########################
		
		#Save size_of_array in $t1
		addi	$t0, $a3, 0
		#Create counter_loop
		li	$t1, 0
		#Create counter_first_array
		li	$t2, 0
		#Create counter_second_array
		li	$t3, 0
		
		#Save starting position of the first array
		addi	$t4, $a0, 0
		#Save starting position of the second array
		addi	$t5, $a2, 0
		
		#Store constant in $t6
		add.s	$f16, $f1, $f29
		
sub_const_1D.s_loop:
		#If counter_loop == size_of_array
		beq	$t1, $t0, sub_const_1D.s_loop_end
		#Else:
		
		#Get current position in the first array_heap
		addi	$t2, $t1, 0
		sll	$t2, $t2, 2
		add	$t2, $t2, $t4
		
		#Get current position in the second array_heap
		addi	$t3, $t1, 0
		sll	$t3, $t3, 2
		add	$t3, $t3, $t5
		
		#Calculate the sub between the current array value and the constant
		#Get value from the first array and store it inside $f15
		l.s	$f15, 0($t2)
		#Do the sub and save it inside $f17
		sub.s	$f17, $f15, $f16

		#Store the value inside the second array
		s.s	$f17, 0($t3)
		
		#Increment counter_loop and recall loop
		addi	$t1, $t1, 1
		j	sub_const_1D.s_loop
		
sub_const_1D.s_loop_end:
		###########################
  		#Restore the previous $f17
		l.s 	$f17, 0($sp)
   		addi 	$sp, $sp, 4
     		#Restore the previous $f16
		l.s 	$f16, 0($sp)
   		addi 	$sp, $sp, 4
       		#Restore the previous $f15
		l.s 	$f15, 0($sp)
   		addi 	$sp, $sp, 4
		#Restore the previous $t5
		lw 	$t5, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t4
		lw 	$t4, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t3
		lw 	$t3, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t2
		lw 	$t2, 0($sp)
   		addi 	$sp, $sp, 4
   		#Restore the previous $t1
		lw 	$t1, 0($sp)
   		addi 	$sp, $sp, 4
  		#Restore the previous $t0
		lw 	$t0, 0($sp)
   		addi 	$sp, $sp, 4
   		###########################
   		
		jr	$ra
