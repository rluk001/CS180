<?php
	include 'serverconnect.php'; //server connection code
	$query = mysqli_query($conn,"Select * from users");
	if($_SERVER["REQUEST_METHOD"] == "POST"){
		$email = mysqli_real_escape_string($conn, $_POST['email']);
		$username = mysqli_real_escape_string($conn, $_POST['username']);
		$password = mysqli_real_escape_string($conn, $_POST['password']);
		$bool = true;
	}
	while($row = mysqli_fetch_array($query,MYSQLI_ASSOC)){
		$table_users = $row['username'];
		//email addition
		$table_emails = $row['email'];
		if($email == $table_emails){
			$bool = false;
			Print '<script>alert("Email has already been registered!");</script>';
			Print '<script>window.location.assign("register.html");</script>';
		}
		//
		if($username == $table_users){
			$bool = false;
			Print '<script>alert("Username has been taken!");</script>';
			Print '<script>window.location.assign("register.html");</script>';
		}
	}
	
        if($bool){
		mysqli_query($conn,"INSERT INTO users (email, username, password) VALUES('$email','$username','$password')");
		//mysqli_query($conn,"INSERT INTO users (username, password) VALUES('$username','$password')");
		Print '<script>alert("Successfully Registered!");</script>';
		Print '<script>window.location.assign("index.php");</script>';
		
	}
?>