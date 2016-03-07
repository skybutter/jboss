package rest.ws;

import java.sql.Timestamp;
import org.codehaus.jackson.annotate.JsonIgnore;

// This is the Data Object for the Web Service call
@SuppressWarnings("serial")
public class Soccer implements java.io.Serializable{
	
	private Integer id ;
    private String value;

	// To use JsonIgnore, you need the add to maven dependency
    @JsonIgnore
    private String groupName;
    
    public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String n) {
		this.groupName = n;
	}

    public Integer getId() {
        return id;
    }

    public String getValue() {
        return value;
    }
    public void setValue(String arg1) {
        value = arg1;
    }

	public String toString(){
		return ("id="+id +", value="+value);
	}
}
