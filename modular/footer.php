<?php
include dirname(__FILE__) . "/../CONFIG.php";
?>
<footer class="row">
  <div class="copyright col-xs-5 col-lg-9">
    <copyright-statement copyrightStart="2017"><span class="hidden-xs">American Society of Mammalogists</span><span class="visible-xs">ASM</span></copyright-statement>
  </div>
  <div class="col-xs-5 col-lg-2" id="git-footer">
    <paper-icon-button icon="glyphicon-social:github" class="click" data-url="<?php echo $gitUrl; ?>" data-toggle="tooltip" title="Visit us on GitHub"></paper-icon-button>
  </div>
  <div class="col-xs-2 col-lg-1" id="bug-footer">
    <paper-icon-button icon="icons:bug-report" class="click" data-url="<?php echo $gitIssueUrl; ?>" data-toggle="tooltip" title="Report a bug"></paper-icon-button>
  </div>
</footer>
