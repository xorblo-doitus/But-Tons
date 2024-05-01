class_name ST

## Not truely a singleton, rather a class with static methods and variables
##
## Not all methods and variables are necessarily used, as some are coming
## from my own template.


## The inial width of the window, as stated in project settings.
## [br][i]Not updated on window resize.
static func get_screen_width() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_width")

## The inial height of the window, as stated in project settings.
## [br][i]Not updated on window resize.
static func get_screen_height() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_height")


## Return whether or not the [code]index[/code]'s bit of [code]mask[/code] is enabled.
static func is_bit_enabled(mask: int, index: int) -> int:
	return mask & (1 << index) == 1

## Return whether or not the [code]index[/code]-th bit of [code]mask[/code] is disabled.
static func is_bit_disabled(mask: int, index: int) -> int:
	return mask & (1 << index) == 0

## Enable the [code]index[/code]-th bit of [code]mask[/code].
## [br][i]Not in place.
func enable_bit(mask: int, index: int) -> int:
	return mask | (1 << index)

## Disable the [code]index[/code]-th bit of [code]mask[/code].
## [br][i]Not in place.
func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)


## Return the given [code]vector[/code] rotated to have the same direction as [code]target[/code].
static func align(vector: Vector2, target: Vector2) -> Vector2:
	return vector.rotated(vector.angle_to(target))


static func datetime_dict_to_string(datetime: Dictionary) -> String:
	return "{year}-{month}-{day}-{hour}h-{minute}min-{second}s".format(
		{
			year = datetime["year"],
			month = "%02d" % datetime["month"],
			day = "%02d" % datetime["day"],
			hour = "%02d" % datetime["hour"],
			minute = "%02d" % datetime["minute"],
			second = "%02d" % datetime["second"],
		}
	)


#static func transform_looking_at(this: Transform3D, target: Vector3, up: Vector3 = Vector3.UP) -> Transform3D:
	#return Transform3D(
		#basis_looking_at(target - this.origin, up),
		#this.origin
	#)
#
#
#static func basis_looking_at(target: Vector3, up: Vector3 = Vector3.UP) -> Basis:
	#var z: Vector3 = target.normalized()
	#
	#var x: Vector3 = up.cross(z);
	#
	#x.normalized()
	#var y: Vector3 = z.cross(x);
	#
	#return Basis(x, y, z)
