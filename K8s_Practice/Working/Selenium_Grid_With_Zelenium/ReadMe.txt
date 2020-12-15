--------Install Zalenium With Helm-------

Make sure you have helm installed.

--------Install with local charts-------
----------------------------------------
$	helm install <heml_release_name> --namespace <your_namespace> .

--------list your heml charts with below command----------
$	helm ls --namespace=<your_namespace>
----------------------------------------
--------Install with remote charts-------
$	helm repo add zalenium-github https://raw.githubusercontent.com/zalando/zalenium/master/charts/zalenium
$	helm install <heml_release_name> --namespace <your_namespace> zalenium-github/zalenium

--------Access your Zalenium pages from below URLs----------

$	http://<NodeIP>:<NodePort>/dashboard/
$	http://<NodeIP>:<NodePort>/grid/admin/live
$	http://<NodeIP>:<NodePort>/grid/console

Insteract with your Zalenium console using VNC with "Interact via VNC"


----------To execute your selenium remotly add below lines in your code----------
 import org.openqa.selenium.*;
 import org.openqa.selenium.remote.DesiredCapabilities;
 import java.net.MalformedURLException;
 import java.net.URL;
 import org.openqa.selenium.remote.RemoteWebDriver;
 import org.testng.Assert;
 import org.testng.annotations.*;
 ##################################
     WebDriver driver;
     String baseURL, nodeURL;
	 
     public void setUp() throws MalformedURLException {
         baseURL = "http://google.com";
         nodeURL = "<ZaleniumgridURL:4444/wd/hub>";
         DesiredCapabilities capability = DesiredCapabilities.chrome();
         capability.setBrowserName("chrome");
         capability.setPlatform(Platform.WIN10);
         driver = new RemoteWebDriver(new URL(nodeURL), capability);
     }
	 
	 <Your test cases>
--------------------------------------------------------------------------------	 