

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    
    coffee: 
      glob_to_multiple:
        expand: true
        flatten: true
        cwd: 'lib'
        src: ['ipc/*.coffee','provider/*.coffee','responder/*.coffee']
        dest: 'js/'
        ext: '.js'
         
    watch:
      scripts:
        files: [
          'lib/ipc/*.coffee'
          'lib/provider/*.coffee'
          'lib/responder/*.coffee'
        ]
        tasks: ['coffee']
      
      config:
        files: ['Gruntfile.coffee']
        options:
          reload: true
    
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  
  grunt.registerTask('default', ['watch'])