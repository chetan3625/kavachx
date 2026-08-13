export const requestResponseLogger = (req, res, next) => {
  const start = Date.now();

  // Create a copy of request body and sanitize sensitive data like password
  let sanitizedBody = null;
  if (req.body) {
    sanitizedBody = { ...req.body };
    if (sanitizedBody.password) {
      sanitizedBody.password = "[HIDDEN]";
    }
  }

  console.log(`\n=================== INCOMING REQUEST ===================`);
  console.log(`TIME:    ${new Date().toISOString()}`);
  console.log(`METHOD:  ${req.method}`);
  console.log(`PATH:    ${req.originalUrl}`);
  if (req.headers.authorization) {
    console.log(`AUTH:    ${req.headers.authorization}`);
  }
  if (sanitizedBody && Object.keys(sanitizedBody).length > 0) {
    console.log(`BODY:    `, JSON.stringify(sanitizedBody, null, 2));
  }
  console.log(`========================================================`);

  // Intercept res.send and res.json to log the response details
  const originalSend = res.send;
  res.send = function (body) {
    const duration = Date.now() - start;

    console.log(`\n=================== OUTGOING RESPONSE ===================`);
    console.log(`TIME:    ${new Date().toISOString()}`);
    console.log(`METHOD:  ${req.method}`);
    console.log(`PATH:    ${req.originalUrl}`);
    console.log(`STATUS:  ${res.statusCode}`);
    console.log(`TIME:    ${duration}ms`);

    if (body) {
      try {
        // If the body is stringified JSON, parse and print formatted
        const parsed = JSON.parse(body);
        console.log(`BODY:    `, JSON.stringify(parsed, null, 2));
      } catch (e) {
        // Non-JSON or already parsed object
        if (typeof body === 'object') {
          console.log(`BODY:    `, JSON.stringify(body, null, 2));
        } else {
          const bodyStr = String(body);
          console.log(`BODY:    `, bodyStr.length > 800 ? `${bodyStr.substring(0, 800)}... (truncated)` : bodyStr);
        }
      }
    }
    console.log(`=========================================================`);

    return originalSend.apply(this, arguments);
  };

  next();
};
