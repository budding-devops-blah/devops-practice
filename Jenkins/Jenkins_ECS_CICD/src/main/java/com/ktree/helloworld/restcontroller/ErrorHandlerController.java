package com.ktree.helloworld.restcontroller;

import org.springframework.boot.autoconfigure.web.ErrorController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
public class ErrorHandlerController implements ErrorController{
	private static final String PATH = "/";
	 @RequestMapping(value=PATH)
	 public String error() {
	  return "Ktree Helloworld";
	 }
	 @Override
	 public String getErrorPath() {
	  return PATH;
	 }
}
