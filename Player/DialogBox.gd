extends CanvasLayer


const dialog_start : Array[String] = [
	"Hey! Lookie here!",
	"I'm the hammer you're holding pal.",
	"Listen up. We got a smithy to run, and the giants ain't gonna be happy if you're diddly-daddlying over here.",
	"I know you were picked involuntarily, but life's life ya know? Ya gotta pick up the slack!",
	"Okay, now that we're on the same page, lemme tell you a couple o' things:",
	"You're here to forge. The giants want you to make swords.",
	"But you ain't ready yet. First you need to practice making a small dagger.",
	"Now, I've given you your first ore to start forging with. Later on, you'll hav'ta find your own ore.",
	"Go on ahead to the room on your left. Activate the lever using your hammer."
]
const dialog_forging : Array[String] = [
	"Now, just wait for a moment until the ore gets dragged down 'ere.",
	"Wait a little bit...",
	"While you're at it, might wanna jump on the walls, now would ya?",
	"Things get hot when you're forging, but there's just two rules you gotta follow:",
	"Don't die, and keep on smacking the ore! Use me to my full potential",
	"I'll leave ya to it then."
]

var current_dialog : Array[String]
var dialog_progress : int = 0

var first_time_forging_dialog_done : bool = false


func _ready() -> void:
	current_dialog = dialog_start
	advance_dialog()


func next_dialog(dialog : String) -> void:
	match dialog:
		"dialog_forging":
			if not first_time_forging_dialog_done:
				current_dialog = dialog_forging
			else:
				return
	dialog_progress = 0
	advance_dialog()


func advance_dialog() -> void:
	$DialogBox.show()
	$TextureRect.show()
	$RichTextLabel.show()
	if dialog_progress >= current_dialog.size():
		$DialogBox.hide()
		$TextureRect.hide()
		$RichTextLabel.hide()
		$Timer.stop()
		return
	$RichTextLabel.text = current_dialog[dialog_progress]
	dialog_progress += 1
	$Timer.start()


func _on_timer_timeout():
	advance_dialog()
