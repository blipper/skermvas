<?php include ('head.php'); ?>
<body>

<!-- MastHead background -->
<div id="MastHead" class="pngfix">
	<!--MastHead Content -->
	<div id="MastHeadInner" class="pngfix">
    	<div id="Intro">	
            <h1>
            <!--  ***** ERROR CODE AND TEXT - EDIT AS REQUIRED -->
            404 Error<br>
			Sorry, we couldn't find the page you were looking for.
            <!-- END OF INTRODUCTION TEXT -->
            </h1>
            
           <!-- ***** Newsletter signup form - YOU CAN USE THE FORM AS IT CURRENLTY IS, OR CHANGE ACTION TO USE YOUR OWN CUSTOM FORM PROCESSOR -->
            <form class="form" id="Search" method="post" action="">
            <p><label for="Term">enter your search here...</label>
            <input type="text" id="Term" name="Term" class="populate term" value="" title="enter your search here...">
            <input id="Submit" class="submit" type="submit" value="Submit"></p>
            </form>

        </div>
    </div>
</div>

<!-- Main content area container -->
<div id="TopBorder" class="pngfix"></div>
<div id="Container" class="pngfix">    
        <!-- Updates -->
        <div id="Information">
            <!-- **** INFORMATION PANEL - EDIT AS REQUIRED. You could give a description of the error, why it might have been caused, what to do, and other info - e.g. link to homepage/other page, contact details, anything! -->
            <p>
            Unfortunately the page you were looking for can't be found. Please use the search feature above, or choose a page from the menu to the right.</p>
            <p><a class="homepage" href="#" title="Go to homepage">Return to homepage</a></p>
        </div>
        
        <!-- ***** SITE MAP MENUS - edit these to reflect your site's structure. Be sure to include your most important & popular pages. Including 'typical' options is recommended - e.g. home, about, services, contact details etc -->
        
        <!-- List One -->
        <ul class="menu">
        	<!-- Heading - if you don't want this to be a heading, and want it styled as the rest of the list items, remove 'class="heading"' -->
            <li class="heading"><a href="#" title="Visit this page">Products</a></li>
            <!-- List Items -->
            <li><a href="#" title="Visit this page">Lorem ipsum</a></li>
            <li><a href="#" title="Visit this page">Dolor sit amet</a></li>
            <li><a href="#" title="Visit this page">Consectetur elit</a></li>
            <li><a href="#" title="Visit this page">Sed tempor incididu</a></li>
            <li><a href="#" title="Visit this page">Ut agna aliqua</a></li>            
        </ul>
        
        
        <!-- List Two -->
        <ul class="menu">
        	<!-- Heading - if you don't want this to be a heading, and want it styled as the rest of the list items, remove 'class="heading"' -->
			<li class="heading"><a href="#" title="Visit this page">Services</a></li>
            <!-- List Items -->
            <li><a href="#" title="Visit this page">Ut agna aliqua</a></li>            
            <li><a href="#" title="Visit this page">Sed tempor incididu</a></li>
            <li><a href="#" title="Visit this page">Lorem ipsum</a></li>
        </ul>


        <!-- List Three -->
        <ul class="menu">
        	<!-- Heading - if you don't want this to be a heading, and want it styled as the rest of the list items, remove 'class="heading"' -->
            <li class="heading"><a href="#" title="Visit this page">Information</a></li>
            <!-- List Items -->
            <li><a href="#" title="Visit this page">Sed tempor incididu</a></li>
            <li><a href="#" title="Visit this page">Consectetur elit</a></li>
            <li><a href="#" title="Visit this page">Dolor sit amet</a></li>
            <li><a href="#" title="Visit this page">Ut agna aliqua</a></li>
        </ul>
		
        <!-- END OF SITE MAP MENUS -->
  	
    <div class="clear"></div> 
</div>

<div id="BottomBorder" class="pngfix"></div>

<!-- Social media icons -->
<div id="Social">
<?php include ('social.php'); ?>
</div>
<div>

</div>

</body>

</html>
