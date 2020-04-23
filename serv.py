from waitress import serve
import hello
serve(hello.app, host='0.0.0.0', port=5000)
