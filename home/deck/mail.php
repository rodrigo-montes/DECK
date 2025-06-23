<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;
require '/root/vendor/autoload.php';
$txt=$argv[1];
    $mail = new PHPMailer(true);

    try {
        $valkey=MD5(date("mdYHisu") . rand(10000000, 15000000)); 
        //Server settings
        // $mail->SMTPDebug = SMTP::DEBUG_SERVER;                      //Enable verbose debug output
        $mail->isSMTP();                                            //Send using SMTP
        $mail->Host       = 'smtp.office365.com';                     //Set the SMTP server to send through
        $mail->SMTPAuth   = true;                                   //Enable SMTP authentication
        $mail->Username   = 'reportes@zoftcom.com';                     //SMTP username
        $mail->Password   = 'Zc0m#2021_';                               //SMTP password
        $mail->SMTPSecure = 'tls'; // PHPMailer::ENCRYPTION_SMTPS;            //Enable implicit TLS encryption
        $mail->Port       = 587;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`
        $mail->CharSet    = "UTF-8";

        //Recipients
        $mail->setFrom('reportes@zoftcom.com', 'ZOFTCOM');
        $mail->addAddress("rodrigo@zoftcom.com", "andres@zoftcom.com");     //Add a recipient
        //$mail->addAddress('ellen@example.com');               //Name is optional
        //$mail->addReplyTo('info@example.com', 'Information');
        //$mail->addCC('cc@example.com');
        //$mail->addBCC('bcc@example.com');

        //Attachments
        //$mail->addAttachment('/tmp/mysql.log.txt');         //Add attachments
        //$mail->addAttachment('/tmp/image.jpg', 'new.jpg');    //Optional name

        //Content
        $mail->isHTML(true);                                  //Set email format to HTML
        $mail->Subject = 'ALERTA: ' . $txt;
        $mail->Body    ='<!DOCTYPE html PUBLIC “-//W3C//DTD XHTML 1.0 Transitional//EN” “https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd”> <html xmlns=“https://www.w3.org/1999/xhtml”>
                        <head>
                            <title>ETL DICE</title>
                            <meta http–equiv=“Content-Type” content=“text/html; charset=UTF-8” />
                            <meta http–equiv=“X-UA-Compatible” content=“IE=edge” />
                            <meta name=“viewport” content=“width=device-width, initial-scale=1.0 “ />
                            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
                        </head>

                        <div class="container">
                            <div class="row ">
                                <div class="col" style="text-align:center">
                                   ETL DICE:
                                </div>
                            </div>
                            <br>
                            <div class="row ">
                                <div class="col" style="text-align:center">
                                    ' . $argv[1] . '
                                </div>
                            </div>
                        </div>
                  ';
        $mail->AltBody = 'ALERTA: ' . $txt;

        $mail->send();
        echo "Message has been sent {$txt}\n";
    } catch (Exception $e) {
    }

?>
