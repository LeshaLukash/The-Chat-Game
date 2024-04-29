tool
extends Node

# БД Аватарок
# Загружаем при старте txt-файл со списком аватарок
# Формируем из него словарь с названиями профилей
# и путей с присвоенными им аватарками

const AVATARS_LIST := "res://avatars/list.txt"

var avatars_db: Dictionary


func _ready():
	avatars_db = load_avatars_list()
	init_avatars_textures()
	print(avatars_db.keys())


# Загрузка файла с текстурами аватарок
func load_avatars_list() -> Dictionary:
	var f = File.new()
	f.open(AVATARS_LIST, File.READ)
	var avatars_list_string: String = f.get_as_text()
	f.close()
	return parse_json(avatars_list_string)


# Загрузка в словарь с аватарки самих аватарок вместо путей к ним
func init_avatars_textures() -> void:
	for key in avatars_db.keys():
		var avatar_path: String = avatars_db[key]
		var avatar_texture: StreamTexture = load(avatar_path)
		avatars_db[key] = avatar_texture


# Запрашиваем текстуру аватарки по имени отправителя
func get_avatar(sender_name := "") -> StreamTexture:
	if avatars_db.has(sender_name):
		return avatars_db[sender_name]
	
	return avatars_db["default"]

