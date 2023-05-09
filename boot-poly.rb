require 'watir'
require 'httparty'

CODE_ACCES = ''
MOT_DE_PASSE = ''
NAISSANCE = ""
TARGET_COURSE = 'PHS1101'
TARGET_GROUP = '01'
BASE_URL = "https://dossieretudiant.polymtl.ca/WebEtudiant7/poly.html"

$log = Logger.new('logs\testPoly.log')

def update
  loop do
    $log.info("lunching the bot")
      it = LaHess.new()
      if it.worked?
        $log.warn("place founded successfully")
        break
      end
      $log.error("No place found for this course")
    $log.info("Sleeping for 5s")
    sleep(5)
  end
end

class LaHess

  def initialize()
    @last_changes_date = Date.new()
    @is_correct_value = false
    connect()
    go_to_change_couses()
  end 

  def worked?
    @is_correct_value
  end

  def connect
    @browser = Watir::Browser.start BASE_URL
    @browser.input(id: "code").set CODE_ACCES
    @browser.input(id: "nip").set MOT_DE_PASSE
    @browser.input(id: "naissance").set NAISSANCE
    @browser.input(type: "submit").click
  end

  def go_to_change_couses
    @browser.input(name: "btnModif").click 
    # nom du cours
    @browser.input(name: "sigle1").set TARGET_COURSE
    # gr theorique
    @browser.input(name: "grtheo1").click
    @browser.input(name: "grtheo1").set TARGET_GROUP
    @browser.input(name: "grlab1").click
    if @browser.alert.exists?
      @browser.alert.ok
      end
    if @browser.alert.exists?
      if @browser.alert.text.include?("Il n'y a plus de places pour le groupe #{TARGET_GROUP} théorie du cours #{TARGET_COURSE}")
        @browser.close
        return @is_correct_value = false
      end
      closeAlertPopup
    end
    
    # groupe pratique
    save
    @browser.close
    return @is_correct_value = true
  end

  def save
    closeAlertPopup

    @browser.input(value: 'Enregistrer').click

    sleep 1
    closeAlertPopup
    $log.info "Submitted"
  end

  def closeAlertPopup
    while @browser.alert.exists?
      $log.debug @browser.alert.text
      sleep 1
      @browser.alert.ok
      
    end
  end

end

update()
