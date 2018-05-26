generate-elm :
	cd external/GoUI && elm make Go.elm --output ../../public/js/Go.js
generate-css :
	scss public/scss/main.scss > public/css/main.css
