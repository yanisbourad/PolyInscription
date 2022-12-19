require 'watir'
require 'httparty'



CODE = ''
NIP = ''
NAISSANCE = ""



TARGET_COURSE = 'LOG2990'
TARGET_GROUP = '02'

BASE_URL = "https://dossieretudiant.polymtl.ca/WebEtudiant7/poly.html"



$log = Logger.new('logs\testPoly.log')
def test
  begin 
    response = HTTParty.get("https://www.horaires.aep.polymtl.ca/make_form2.php?courses=#{TARGET_COURSE}")
    it = !response.body.include?("closed\">#{TARGET_GROUP}<input name=\"l_#{TARGET_COURSE}_#{TARGET_GROUP}\"")
    $log.info("FirstTestResponse #{it.to_s}")
    puts it
    return it
  rescue Exception => e
    $log.warn("Error in test : #{e}")
    sleep 60
    return false
  end
end

def update
  loop do
    has_spot = test
    if has_spot
      $log.info("lunching the bot")
      it = LaHess.new()
      if it.worked?
        $log.warn("successfully")
        break
      end
      $log.error("the bot was not successful")
    end
    $log.info("Sleeping for 50s")
    sleep(50)
  end
end

class LaHess

  def initialize()
    @last_changes_date = Date.new()
    
    connect()
    $log.info("the connection was successful")
    go_to_change_couses()
  end 

  def worked?
    @is_correct_value
  end

  def connect
    @browser = Watir::Browser.start BASE_URL
    @browser.input(id: "code").set CODE
    @browser.input(id: "nip").set NIP
    @browser.input(id: "naissance").set NAISSANCE
    @browser.input(type: "submit").click
  end

  def go_to_change_couses
    @browser.input(name: "btnModif").click 
    index = @browser.input(value: TARGET_COURSE).name[-1]
    element = @browser.input(name: "grlab#{index}")
    @browser.input(name: "grlab#{index}")
    script = "console.log(arguments[0].value= #{TARGET_GROUP})"
    @browser.execute_script(script, element)
    @browser.input(name: "grlab#{index}").fire_event('onchange')
    sleep 1
    if @browser.alert.exists?
      $log.debug "Alert when changing the lab number: #{@browser.alert.text} "
      nike_le_alert
    end
    sleep 3
    @is_correct_value = (@browser.input(name: "grlab#{index}").value == TARGET_GROUP)
    if @is_correct_value
      save
    end
    @browser.close
  end

  def save
    nike_le_alert

    @browser.input(value: 'Enregistrer').click

    sleep 3
    nike_le_alert
    sleep 3
    $log.info "Submitted"
  end

  def nike_le_alert
    while @browser.alert.exists?
      $log.debug @browser.alert.text
      @browser.alert.ok
    end
  end

end

update()