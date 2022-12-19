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
  response = HTTParty.get("https://www.horaires.aep.polymtl.ca/make_form2.php?courses=LOG2990")
  it = !response.body.include?('closed">02<input name="l_LOG2990_02"')
  $log.info("FirstTestResponse #{it.to_s}")
  puts it
  it
end

def update
  loop do
    has_spot = test
    if has_spot
      it = LaHess.new()
      $log.info("lunching the bot")
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
    reussit= true
    sleep 1
    if @browser.alert.exists?
      $log.debug "Alert when changing the lab number: #{@browser.alert.text} "
      reussit = !@browser.alert.text.include?("Il n'y a plus de places pour le groupe")
      @browser.alert.ok
    end
    @is_correct_value = (@browser.input(name: "grlab#{index}").value == TARGET_GROUP)
    if reussit && @is_correct_value
      save
    end
    @browser.close
  end

  def save
    @browser.input(value: 'Enregistrer').click
    if @browser.alert.exists?
      $log.debug @browser.alert.text
      @browser.alert.ok
    end
    $log.info "Submitted"
  end
end

update()