
module.exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'SG Terraform Lambda Deployed. However, the desired functionality is not yet implemented';
  
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: responseMessage,
      }),
    }
  }