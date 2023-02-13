const crypto = require('crypto');
const express = require('express');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');
const { serializeDictionary } = require('structured-headers');
const { setTimeout } = require('timers/promises');

const app = express();
let server;

let messages = [];
let logEntries = [];
let responsesToServe = [];

let updateRequest = null;

let multipartResponseToServe = null;
let requestedStaticFiles = [];

function start(port) {
  if (!server) {
    server = app.listen(port);
  }
}

function stop() {
  if (server) {
    server.close();
    server = null;
  }
  messages = [];
  logEntries = [];
  responsesToServe = [];
  updateRequest = null;
  multipartResponseToServe = null;
  requestedStaticFiles = [];
}

function consumeRequestedStaticFiles() {
  const returnArray = requestedStaticFiles;
  requestedStaticFiles = [];
  return returnArray;
}

app.use(express.json());
app.use('/static', (req, res, next) => {
  requestedStaticFiles.push(path.basename(req.url));
  next();
});
app.use('/static', express.static(path.resolve(__dirname, '..', '.static')));

app.get('/notify/:string', (req, res) => {
  messages.push(req.params.string);
  res.set('Cache-Control', 'no-store');
  if (responsesToServe[0]) {
    res.json(responsesToServe.shift());
  } else {
    res.send('Received request');
  }
});

app.post('/post', (req, res) => {
  messages.push(req.body);
  res.set('Cache-Control', 'no-store');
  if (responsesToServe[0]) {
    res.json(responsesToServe.shift());
  } else {
    res.send('Received request');
  }
});

app.post('/log', (req, res) => {
  logEntries = req.body.logEntries || [];
  res.set('Cache-Control', 'no-store');
  res.send('Received request');
});

async function waitForRequest(timeout, responseToServe) {
  const finishTime = new Date().getTime() + timeout;

  if (responseToServe) {
    responsesToServe.push(responseToServe);
  }

  while (!messages.length) {
    const currentTime = new Date().getTime();
    if (currentTime >= finishTime) {
      throw new Error('Timed out waiting for message');
    }
    await setTimeout(50);
  }

  return messages.shift();
}

async function waitForLogEntries(timeout) {
  const finishTime = new Date().getTime() + timeout;

  while (!logEntries.length && server) {
    const currentTime = new Date().getTime();
    if (currentTime >= finishTime) {
      throw new Error('Timed out waiting for message');
    }
    if (!server) {
      throw new Error('Server killed while waiting for message');
    }
    await setTimeout(50);
  }

  return logEntries;
}

app.get('/update', (req, res) => {
  updateRequest = req;
  if (multipartResponseToServe) {
    const form = new FormData();

    if (multipartResponseToServe.manifest) {
      form.append('manifest', JSON.stringify(multipartResponseToServe.manifest), {
        contentType: 'application/json',
        header: {
          'content-type': 'application/json; charset=utf-8',
          'expo-signature': multipartResponseToServe.manifestSignature,
        },
      });
    }

    if (multipartResponseToServe.directive) {
      form.append('directive', JSON.stringify(multipartResponseToServe.directive), {
        contentType: 'application/json',
        header: {
          'content-type': 'application/json; charset=utf-8',
          'expo-signature': multipartResponseToServe.directiveSignature,
        },
      });
    }

    res.statusCode = 200;
    res.setHeader('expo-protocol-version', 1);
    res.setHeader('expo-sfv-version', 0);
    res.setHeader('cache-control', 'private, max-age=0');
    res.setHeader('content-type', `multipart/mixed; boundary=${form.getBoundary()}`);
    res.write(form.getBuffer());
    res.end();
  } else {
    res.status(404).send('No update available');
  }
});

async function waitForUpdateRequest(timeout) {
  const finishTime = new Date().getTime() + timeout;
  while (!updateRequest && server) {
    const currentTime = new Date().getTime();
    if (currentTime >= finishTime) {
      throw new Error('Timed out waiting for update request');
    }
    if (!server) {
      throw new Error('Server killed while waiting for update');
    }
    await setTimeout(50);
  }

  const request = updateRequest;
  updateRequest = null;
  return request;
}

async function getPrivateKeyAsync(projectRoot) {
  const codeSigningPrivateKeyPath = path.join(projectRoot, 'keys', 'private-key.pem');
  const pemBuffer = fs.readFileSync(path.resolve(codeSigningPrivateKeyPath));
  return pemBuffer.toString('utf8');
}

function signRSASHA256(data, privateKey) {
  const sign = crypto.createSign('RSA-SHA256');
  sign.update(data, 'utf8');
  sign.end();
  return sign.sign(privateKey, 'base64');
}

function convertToDictionaryItemsRepresentation(obj) {
  return new Map(
    Object.entries(obj).map(([k, v]) => {
      return [k, [v, new Map()]];
    })
  );
}

async function serveSignedManifest(manifest, projectRoot) {
  const privateKey = await getPrivateKeyAsync(projectRoot);
  const manifestString = JSON.stringify(manifest);
  const hashSignature = signRSASHA256(manifestString, privateKey);
  const dictionary = convertToDictionaryItemsRepresentation({
    sig: hashSignature,
    keyid: 'main',
  });
  const signature = serializeDictionary(dictionary);
  multipartResponseToServe = {
    manifest,
    manifestSignature: signature,
  };
}

async function serveSignedDirective(directive, projectRoot) {
  const privateKey = await getPrivateKeyAsync(projectRoot);
  const directiveString = JSON.stringify(directive);
  const hashSignature = signRSASHA256(directiveString, privateKey);
  const dictionary = convertToDictionaryItemsRepresentation({
    sig: hashSignature,
    keyid: 'main',
  });
  const signature = serializeDictionary(dictionary);
  multipartResponseToServe = {
    directive,
    directiveSignature: signature,
  };
}

const Server = {
  start,
  stop,
  waitForLogEntries,
  waitForRequest,
  waitForUpdateRequest,
  serveSignedManifest,
  serveSignedDirective,
  consumeRequestedStaticFiles,
};

module.exports = Server;
