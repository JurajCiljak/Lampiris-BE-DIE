/*
    @Author: Juraj Ciljak
    @Date: 27.09.2017
    @Description: Class is developed for handling Exceptions
    @Version: 1.0.1
*/ 

public without sharing class ErrorException extends Exception{
    public String ErrorType {get;set;}
    public String ErrorDescription {get;set;}

    public ErrorException(String ErrType, String ErrDesc) {
        this(ErrType+':'+ErrDesc);
        this.ErrorType = ErrType;
        this.ErrorDescription = ErrDesc;

    }
    
    
}