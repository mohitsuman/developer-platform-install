'use strict';

let path = require('path');
let fs = require('fs-extra');

import Logger from '../../services/logger';
import Util from '../../model/helpers/util';
import Platform from '../../services/platform';

class StartController {

  constructor(installerDataSvc, electron) {
    this.installerDataSvc = installerDataSvc;
    this.electron = electron;
    this.devstudioInstall = this.installerDataSvc.getInstallable('devstudio');
    this.fuseInstall = this.installerDataSvc.getInstallable('fusetools');
    this.cdkInstall = this.installerDataSvc.getInstallable('cdk');
    this.electron.remote.getCurrentWindow().removeAllListeners('close');
    this.launchDevstudio = this['launchDevstudio_' + Platform.OS];
  }
  
  static get START_CDK_URL () {
    return 'https://developers.redhat.com/products/cdk/hello-world/#cdk_build-your-first-app';
  }

  fetchMiscComponents() {
    let miscComponents = [];
    this.removeComponents('devstudio');
    this.removeComponents('cdk');
    for (let [key, value] of this.installerDataSvc.allInstallables()) {
      if(value.installed && key!=="devstudio" && key!=="cdk" && key!==undefined){
        miscComponents.push(value);
      }
    }
    return miscComponents;
  }

  removeComponents(key) {
    for(let list of this.installerDataSvc.getInstallable(key).dependenciesOf){
      this.installerDataSvc.allInstallables().delete(list.keyName);
    }
    return;
  }

  startDevstudio() {
    if(this.devstudioInstall.isSkipped() && this.fuseInstall.isSkipped()) {
      this.exit();
    } else {
      this.launchDevstudio();
    }
  }

  startCdk() {
    this.electron.shell.openExternal(StartController.START_CDK_URL);
  }

  launchDevstudio_darwin() {
    let devStudioAppPath = path.join(this.installerDataSvc.devstudioDir(), 'Devstudio.app');
    let options = {
      env : Object.assign({}, Platform.ENV)
    };
    options.env['rhel.subscription.password'] = this.installerDataSvc.password;
    return Util.executeCommand(`open '${devStudioAppPath}'`, 1, options).then(()=>{
      Logger.info('devstudio started sucessfully');
      this.exit();
    }).catch((error)=>{
      Logger.error(`devstudio start failed with error code '${error}'`);
      this.exit();
      return Promise.reject(error);
    });
  }

  launchDevstudio_win32() {
    Logger.info('devstudio Start - Write temp files...');

    let resetvarsBatFile = path.join(this.installerDataSvc.tempDir(), 'resetvars.bat');
    let resetvarsVbsFile = path.join(this.installerDataSvc.tempDir(), 'resetvars.vbs');
    let resetvarsVbsFileData = [
      'Set oShell = WScript.CreateObject("WScript.Shell")',
      'filename = oShell.ExpandEnvironmentStrings("' + resetvarsBatFile + '")',
      'Set objFileSystem = CreateObject("Scripting.fileSystemObject")',
      'Set oFile = objFileSystem.CreateTextFile(filename, TRUE)',

      'set oEnv=oShell.Environment("System")',
      'for each sitem in oEnv',
      'oFile.WriteLine("SET " & sitem)',
      'next',
      'path = oEnv("PATH")',

      'set oEnv=oShell.Environment("User")',
      'for each sitem in oEnv',
      'oFile.WriteLine("SET " & sitem)',
      'next',

      'path = path & ";" & oEnv("PATH")',
      'oFile.WriteLine("SET PATH=" & path)',
      'oFile.Close'
    ].join('\r\n');
    Logger.info('devstudio Start - Write resetvarsVbsFile: ' + resetvarsVbsFile);
    fs.writeFileSync(resetvarsVbsFile, resetvarsVbsFileData);
    Logger.info('devstudio Start - Write resetvarsVbsFile: ' + resetvarsVbsFile + ' - SUCCESS');

    let runDevstudioFile = path.join(this.installerDataSvc.tempDir(), 'rundevstudio.bat');
    let runDevstudioFileData = [
      '"' + resetvarsVbsFile + '"',
      'call "' + resetvarsBatFile + '"',
      'cd "' + this.installerDataSvc.devstudioDir() + '"',
      'call devstudio.bat'
    ].join('\r\n');
    Logger.info('devstudio Start - Write runDevstudioFile: ' + runDevstudioFile);
    fs.writeFileSync(runDevstudioFile, runDevstudioFileData);

    Logger.info('devstudio Start - Write runDevstudioFile: ' + runDevstudioFile + ' - SUCCESS');
    Logger.info('devstudio Start - Write temp file SUCCESS');
    Logger.info('devstudio Start - Run runDevstudioFile: ' + runDevstudioFile);

    let env = Platform.ENV;
    env['rhel.subscription.password'] = this.installerDataSvc.password;
    let runDevstudioBat = require('child_process').spawn(
      'cmd.exe', ['/c', runDevstudioFile], { env, timeout: 2000 });

    runDevstudioBat.stdout.on('data',
      (data) => {
        Logger.info(`devstudio Start - [${runDevstudioFile}]: ${data}`);
      });
    runDevstudioBat.stderr.on('data',
      (data) => {
        Logger.info(`devstudio Start ERROR - [${runDevstudioFile}]: ${data}`);
      });
    runDevstudioBat.on('exit',
      (code) => {
        Logger.info(`devstudio Start Exit - Code: ${code}`);
        this.exit();
      });
  }

  launchDevstudio_linux() {
    // TBD
  }

  exit() {
    Logger.info('Closing the installer window');
    this.electron.remote.getCurrentWindow().close();
  }
}

StartController.$inject = ['installerDataSvc', 'electron'];

export default StartController;
