#!/usr/bin/env ruby
# Скрипт для добавления Push Notifications capability и Background Modes
# в Runner и .ntfs targets

require 'securerandom'

PBXPROJ_PATH = 'ios/Runner.xcodeproj/project.pbxproj'
RUNNER_DIR = 'ios/Runner'
NOTIFICATIONS_DIR = 'ios/.ntfs'
RUNNER_ENTITLEMENTS = "#{RUNNER_DIR}/Runner.entitlements"
NOTIFICATIONS_ENTITLEMENTS = "#{NOTIFICATIONS_DIR}/.ntfs.entitlements"
INFO_PLIST = "#{RUNNER_DIR}/Info.plist"

GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
NC = "\033[0m"

# Генерация уникального ID в формате Xcode (24 символа hex)
def generate_id
  SecureRandom.hex(12).upcase
end

# Проверяем наличие project.pbxproj
unless File.exist?(PBXPROJ_PATH)
  puts "#{RED}❌ Файл #{PBXPROJ_PATH} не найден#{NC}"
  exit 1
end

content = File.read(PBXPROJ_PATH)

# ============================================
# 1. Создаем/обновляем Runner.entitlements
# ============================================
puts "#{YELLOW}📝 Настройка Runner.entitlements...#{NC}"

runner_entitlements_content = <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
</dict>
</plist>
PLIST

File.write(RUNNER_ENTITLEMENTS, runner_entitlements_content)
puts "#{GREEN}   ✓ Runner.entitlements создан#{NC}"

# ============================================
# 2. Создаем/обновляем .ntfs.entitlements
# ============================================
if Dir.exist?(NOTIFICATIONS_DIR)
  puts "#{YELLOW}📝 Настройка .ntfs.entitlements...#{NC}"
  
  notifications_entitlements_content = <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
</dict>
</plist>
PLIST

  File.write(NOTIFICATIONS_ENTITLEMENTS, notifications_entitlements_content)
  puts "#{GREEN}   ✓ .ntfs.entitlements создан#{NC}"
else
  puts "#{YELLOW}   ⚠️  Директория .ntfs не найдена, пропускаем...#{NC}"
end

# ============================================
# 3. Добавляем Runner.entitlements в проект
# ============================================
puts "#{YELLOW}🔧 Добавление Runner.entitlements в проект...#{NC}"

# Проверяем, не добавлен ли уже файл
unless content.include?('Runner.entitlements')
  runner_entitlements_file_ref = generate_id
  
  # Добавляем PBXFileReference
  content.gsub!(/\/\* End PBXFileReference section \*\//) do
    "\t\t#{runner_entitlements_file_ref} /* Runner.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Runner.entitlements; sourceTree = \"<group>\"; };\n/* End PBXFileReference section */"
  end
  
  # Добавляем в Runner group (97C146F01CF9000F007C117D)
  content.gsub!(/(97C146F01CF9000F007C117D \/\* Runner \*\/ = \{[^}]*children = \()([^)]*\);)/) do
    prefix = $1
    files = $2
    "#{prefix}\n\t\t\t\t#{runner_entitlements_file_ref} /* Runner.entitlements */,#{files}"
  end
  
  puts "#{GREEN}   ✓ Runner.entitlements добавлен в проект#{NC}"
else
  # Получаем ID существующего файла
  runner_entitlements_file_ref = content.match(/(\w{24}) \/\* Runner\.entitlements \*\//)&.[](1)
  puts "#{YELLOW}   ⚠️  Runner.entitlements уже в проекте#{NC}"
end

# ============================================
# 4. Добавляем .ntfs.entitlements в проект
# ============================================
if Dir.exist?(NOTIFICATIONS_DIR) && !content.include?('.ntfs.entitlements')
  puts "#{YELLOW}🔧 Добавление .ntfs.entitlements в проект...#{NC}"
  
  notif_entitlements_file_ref = generate_id
  
  # Добавляем PBXFileReference
  content.gsub!(/\/\* End PBXFileReference section \*\//) do
    "\t\t#{notif_entitlements_file_ref} /* .ntfs.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = .ntfs.entitlements; sourceTree = \"<group>\"; };\n/* End PBXFileReference section */"
  end
  
  # Добавляем в .ntfs group (NOTIF003000000000000001)
  content.gsub!(/(NOTIF003000000000000001 \/\* .ntfs \*\/ = \{[^}]*children = \()([^)]*\);)/) do
    prefix = $1
    files = $2
    "#{prefix}\n\t\t\t\t#{notif_entitlements_file_ref} /* .ntfs.entitlements */,#{files}"
  end
  
  puts "#{GREEN}   ✓ .ntfs.entitlements добавлен в проект#{NC}"
elsif Dir.exist?(NOTIFICATIONS_DIR)
  notif_entitlements_file_ref = content.match(/(\w{24}) \/\* \.ntfs\.entitlements \*\//)&.[](1)
  puts "#{YELLOW}   ⚠️  .ntfs.entitlements уже в проекте#{NC}"
end

# ============================================
# 5. Добавляем CODE_SIGN_ENTITLEMENTS в Runner build settings
# ============================================
puts "#{YELLOW}🔐 Настройка CODE_SIGN_ENTITLEMENTS для Runner...#{NC}"

# Runner Debug (97C147061CF9000F007C117D)
unless content =~ /97C147061CF9000F007C117D.*?CODE_SIGN_ENTITLEMENTS/m
  content.gsub!(/(97C147061CF9000F007C117D \/\* Debug \*\/ = \{[^}]*buildSettings = \{)/) do
    "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"
  end
end

# Runner Release (97C147071CF9000F007C117D)
unless content =~ /97C147071CF9000F007C117D.*?CODE_SIGN_ENTITLEMENTS/m
  content.gsub!(/(97C147071CF9000F007C117D \/\* Release \*\/ = \{[^}]*buildSettings = \{)/) do
    "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"
  end
end

# Runner Profile (249021D4217E4FDB00AE95B9)
unless content =~ /249021D4217E4FDB00AE95B9.*?CODE_SIGN_ENTITLEMENTS/m
  content.gsub!(/(249021D4217E4FDB00AE95B9 \/\* Profile \*\/ = \{[^}]*buildSettings = \{)/) do
    "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"
  end
end

puts "#{GREEN}   ✓ CODE_SIGN_ENTITLEMENTS настроен для Runner#{NC}"

# ============================================
# 6. Добавляем CODE_SIGN_ENTITLEMENTS в .ntfs build settings
# ============================================
if Dir.exist?(NOTIFICATIONS_DIR)
  puts "#{YELLOW}🔐 Настройка CODE_SIGN_ENTITLEMENTS для .ntfs...#{NC}"
  
  # .ntfs Debug (NOTIF014000000000000001)
  unless content =~ /NOTIF014000000000000001.*?CODE_SIGN_ENTITLEMENTS/m
    content.gsub!(/(NOTIF014000000000000001 \/\* Debug \*\/ = \{[^}]*buildSettings = \{)/) do
      "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = .ntfs/.ntfs.entitlements;"
    end
  end
  
  # .ntfs Release (NOTIF015000000000000001)
  unless content =~ /NOTIF015000000000000001.*?CODE_SIGN_ENTITLEMENTS/m
    content.gsub!(/(NOTIF015000000000000001 \/\* Release \*\/ = \{[^}]*buildSettings = \{)/) do
      "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = .ntfs/.ntfs.entitlements;"
    end
  end
  
  # .ntfs Profile (NOTIF016000000000000001)
  unless content =~ /NOTIF016000000000000001.*?CODE_SIGN_ENTITLEMENTS/m
    content.gsub!(/(NOTIF016000000000000001 \/\* Profile \*\/ = \{[^}]*buildSettings = \{)/) do
      "#{$1}\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = .ntfs/.ntfs.entitlements;"
    end
  end
  
  puts "#{GREEN}   ✓ CODE_SIGN_ENTITLEMENTS настроен для .ntfs#{NC}"
end

# ============================================
# 7. Добавляем Background Modes в Info.plist
# ============================================
puts "#{YELLOW}🔔 Настройка Background Modes в Info.plist...#{NC}"

info_plist_content = File.read(INFO_PLIST)

unless info_plist_content.include?('UIBackgroundModes')
  # Добавляем UIBackgroundModes перед </dict>
  background_modes = <<-PLIST
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
		<string>remote-notification</string>
	</array>
PLIST
  
  info_plist_content.gsub!(/<\/dict>\s*<\/plist>/) do
    "#{background_modes}</dict>\n</plist>"
  end
  
  File.write(INFO_PLIST, info_plist_content)
  puts "#{GREEN}   ✓ Background Modes добавлены (fetch, remote-notification)#{NC}"
else
  # Проверяем наличие нужных режимов
  has_fetch = info_plist_content.include?('<string>fetch</string>')
  has_remote = info_plist_content.include?('<string>remote-notification</string>')
  
  if has_fetch && has_remote
    puts "#{YELLOW}   ⚠️  Background Modes уже настроены#{NC}"
  else
    # Нужно добавить отсутствующие режимы
    unless has_fetch
      info_plist_content.gsub!(/<key>UIBackgroundModes<\/key>\s*<array>/) do
        "<key>UIBackgroundModes</key>\n\t<array>\n\t\t<string>fetch</string>"
      end
    end
    unless has_remote
      info_plist_content.gsub!(/<key>UIBackgroundModes<\/key>\s*<array>/) do
        "<key>UIBackgroundModes</key>\n\t<array>\n\t\t<string>remote-notification</string>"
      end
    end
    File.write(INFO_PLIST, info_plist_content)
    puts "#{GREEN}   ✓ Background Modes обновлены#{NC}"
  end
end

# Записываем project.pbxproj
File.write(PBXPROJ_PATH, content)

puts "#{GREEN}✅ Capabilities настроены успешно!#{NC}"
puts ""
puts "#{YELLOW}📋 Добавлено:#{NC}"
puts "   • Push Notifications capability для Runner"
puts "   • Push Notifications capability для .ntfs (если существует)"
puts "   • Background Modes: Remote notifications, Background fetch"
puts ""
puts "#{YELLOW}⚠️  Примечание:#{NC}"
puts "   После сборки для production измените aps-environment на 'production'"
puts "   в файлах Runner.entitlements и .ntfs.entitlements"
