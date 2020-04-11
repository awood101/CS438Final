extends Label


func increment_resource():
	var temp = int(text)
	temp += 1
	text = str(temp)
