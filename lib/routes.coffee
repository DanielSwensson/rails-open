exec = require("child_process").exec

class Routes
  getUri: (controllerName) ->
    return new Promise (resolve, reject) ->
      cmd = "CONTROLLER=#{controllerName} #{atom.config.get('rails-open.command')} routes | grep '#index'"
      child = exec(
        cmd,
        cwd: atom.project.getPaths()[0],
        encoding: 'utf8',
        (error, stdout, stderr) ->
          if error
            reject reason: "Error executing '#{cmd}'. Error: #{stderr}"
          else
            try
              resolve stdout.trim().split(/\s+/)[2].replace('(.:format)', '')
            catch err
              reject reason: "Cant find route for #{controllerName}"
      )

module.exports = Routes
